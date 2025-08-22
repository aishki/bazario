<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config/supabase_client.php';

$supabase = new SupabaseClient();
$data = json_decode(file_get_contents("php://input"));

if ($data->action == "login") {
    if (empty($data->email) || empty($data->password)) {
        http_response_code(400);
        echo json_encode(["status" => "error", "message" => "Email and password are required"]);
        exit;
    }

    try {
        $users = $supabase->query(
            "users",
            "id,email,password_hash,role,vendors(id,business_name)",
            ["email" => "eq." . $data->email]
        );

        if (count($users) > 0) {
            $user = $users[0];
            if (password_verify($data->password, $user['password_hash'])) {
                $token = bin2hex(random_bytes(32));
                $response = [
                    "status" => "success",
                    "message" => "Login successful",
                    "user_id" => $user['id'],
                    "email" => $user['email'],
                    "role" => $user['role'],
                    "token" => $token
                ];
                if ($user['role'] === 'vendor' && !empty($user['vendors'])) {
                    $vendor = $user['vendors'][0];
                    $response['vendor_id'] = $vendor['id'];
                    $response['business_name'] = $vendor['business_name'];
                }
                echo json_encode($response);
            } else {
                http_response_code(401);
                echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
            }
        } else {
            http_response_code(401);
            echo json_encode(["status" => "error", "message" => "User not found"]);
        }
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(["status" => "error", "message" => "Database error: " . $e->getMessage()]);
    }
} elseif ($data->action == "register") {
    if (empty($data->email) || empty($data->password) || empty($data->first_name) || empty($data->last_name) || empty($data->username)) {
        http_response_code(400);
        echo json_encode(["status" => "error", "message" => "Email, password, first name, last name, and username are required"]);
        exit;
    }

    try {
        // 🔎 Check if email/username exists
        $existing_check = $supabase->query(
            "users",
            "email,username",
            ["or" => "(email.eq." . $data->email . ",username.eq." . $data->username . ")"]
        );
        foreach ($existing_check as $existing) {
            if ($existing['email'] === $data->email) {
                http_response_code(409);
                echo json_encode(["status" => "error", "message" => "Email already exists"]);
                exit;
            }
            if ($existing['username'] === $data->username) {
                http_response_code(409);
                echo json_encode(["status" => "error", "message" => "Username already exists"]);
                exit;
            }
        }

        $password_hash = password_hash($data->password, PASSWORD_DEFAULT, ['cost' => 10]);
        $role = isset($data->role) ? strtolower($data->role) : 'customer';
        $now = date("Y-m-d H:i:s");

        // ✅ Insert into users
        $user_data = [
            "email" => $data->email,
            "username" => $data->username,
            "password_hash" => $password_hash,
            "role" => $role,
            "created_at" => $now
        ];
        $new_user = $supabase->insert("users", $user_data);

        if ($new_user) {
            $user_id = $new_user[0]['id'];
            $response = [
                "status" => "success",
                "message" => "Registration successful",
                "user_id" => $user_id,
                "role" => $role
            ];

            try {
                if ($role === 'customer') {
                    // ✅ Insert into customers
                    $customer_data = [
                        "id" => $user_id,
                        "first_name" => $data->first_name,
                        "middle_name" => $data->middle_name ?? null,
                        "last_name" => $data->last_name,
                        "suffix" => $data->suffix ?? null,
                        "phone_number" => $data->phone ?? null,
                        "created_at" => $now
                    ];
                    $supabase->insert("customers", $customer_data);
                } elseif ($role === 'vendor') {
                    // ✅ Insert into vendors
                    $vendor_data = [
                        "id" => $user_id,
                        "business_name" => !empty($data->business_name) ? $data->business_name : "New Business",
                        "description" => $data->business_description ?? null,
                        "business_category" => $data->business_category ?? null,
                        "created_at" => $now
                    ];
                    $supabase->insert("vendors", $vendor_data);

                    // ✅ Insert into vendor_contacts
                    $contact_data = [
                        "id" => $user_id,
                        "first_name" => $data->first_name,
                        "middle_name" => $data->middle_name ?? null,
                        "last_name" => $data->last_name,
                        "suffix" => $data->suffix ?? null,
                        "phone_number" => $data->phone ?? null,
                        "email" => $data->email,
                        "position" => !empty($data->position) ? $data->position : "Owner",
                        "created_at" => $now
                    ];
                    $supabase->insert("vendor_contacts", $contact_data);

                    $response['vendor_id'] = $user_id;
                    $response['business_name'] = $vendor_data['business_name'];
                }
            } catch (Exception $e) {
                error_log("Secondary profile creation failed for user $user_id: " . $e->getMessage());
            }

            echo json_encode($response);
        } else {
            http_response_code(500);
            echo json_encode(["status" => "error", "message" => "Registration failed"]);
        }
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(["status" => "error", "message" => "Database error: " . $e->getMessage()]);
    }
}
