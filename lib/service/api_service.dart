import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String baseUrlAuth = "http://192.168.10.36:18100/api/auth";
  // static const String baseUrlUser = "http://192.168.10.36:18100/api/user";
  // static const String baseUrlBanks = "http://192.168.10.36:18104/api/banks";
  // static const String baseUrlSavings = "http://192.168.10.36:18104/api/savingPolicy";
  // static const String baseUrlSAVINGSERVICE = "http://192.168.10.36:18103/api/saving";

static const String baseUrlAuth = "http://192.168.91.13:18100/api/auth";
  
  static const String baseUrlUser = "http://192.168.91.13:18100/api/user";
  static const String baseUrlBanks = "http://192.168.91.13:18104/api/banks";
  static const String baseUrlSavings ="http://192.168.91.13:18104/api/savingPolicy";
  static const String baseUrlSAVINGSERVICE ="http://192.168.91.13:18103/api/saving";

  // Login function
  static Future<Map<String, dynamic>> login(
    String phoneNumber,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrlAuth/login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"phoneNumber": phoneNumber, "password": password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Access the nested token in the response
        final token = responseData["data"]?["token"]?.toString();
        if (token == null || token.isEmpty) {
          throw Exception(
            "Authentication token is empty or not in expected format",
          );
        }

        // Get other user data from the nested structure
        final userName = responseData["data"]?["userName"]?.toString();
        final responsePhoneNumber =
            responseData["data"]?["phoneNumber"]?.toString();

        // Save credentials with error handling
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("authToken", token);
          await prefs.setString("phoneNumber", phoneNumber);
          if (userName != null) {
            await prefs.setString("userName", userName);
          }

          // Verify storage
          final savedToken = prefs.getString("authToken");
          final savedPhone = prefs.getString("phoneNumber");

          if (savedToken != token || savedPhone != phoneNumber) {
            throw Exception("Failed to persist authentication data");
          }
        } catch (storageError) {
          throw Exception("Local storage error: $storageError");
        }

        return {
          "success": true,
          "token": token,
          "phoneNumber": phoneNumber,
          "userName": userName,
          "message": "Login successful",
        };
      } else {
        // Handle specific HTTP status codes
        final errorMsg = switch (response.statusCode) {
          404 => "Phone number not found",
          401 => "Invalid password",
          400 => "Invalid request format",
          500 => "Server error",
          _ => "Login failed with status ${response.statusCode}",
        };
        throw Exception(errorMsg);
      }
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
        "message":
            "Login failed: ${e is Exception ? e.toString() : 'Unknown error'}",
      };
    }
  }

  // Register function
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String surname,
    required String email,
    required String cniNumber,
    required String cniExpiration,
    required String phoneNumber,
    required String password,
    required String internalId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrlAuth/register"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "surname": surname,
          "email": email,
          "cniNumber": cniNumber,
          "cniExpiration": cniExpiration,
          "phoneNumber": phoneNumber,
          "password": password,
          "internalId": internalId,
        }),
      );

      // Debugging print
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': responseData['meta']?['statusCode'] == 1073741824,
          'message': responseData['meta']['message'] ?? 'Operation completed',
          'data': responseData['data'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': responseData['meta']['message'] ?? 'Error occurred',
          'errors': responseData['errors'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Send OTP and store phone number
  static Future<void> sendOtp(String phoneNumber) async {
    final response = await http.post(
      Uri.parse("$baseUrlAuth/sendOtp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phoneNumber": phoneNumber}),
    );

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("phoneNumber", phoneNumber);
      print("OTP sent successfully: ${response.body}");
    } else {
      print("Failed to send OTP: ${response.body}");
      throw Exception("Échec de l'envoi de l'OTP");
    }
  }

  // Verify if the phone number exists
  static Future<bool> verifyPhoneNumber(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrlAuth/verifyPhone/$phoneNumber"),
        headers: {'accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['message'] == "Phone number found";
      }
      return false;
    } catch (e) {
      print("Error verifying phone: $e");
      return false;
    }
  }

  // Verify OTP (fetching phone number from memory)
  static Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final body = jsonEncode({
        "phoneNumber": phoneNumber.trim(),
        "otp": otp.trim(),
      });
      
      print("Sending OTP Request: $body");

      final response = await http.post(
        Uri.parse("$baseUrlAuth/verifyOtp"),
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(const Duration(seconds: 30));

         final responseData = jsonDecode(response.body);
        print("Full API Response: $responseData");  
    

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': responseData['meta']['message'] ?? 
                  (response.statusCode == 200 ? 'Success' : 'Failed'),
        'data': responseData['data'],
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please try again',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network',
      };
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid server response format',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Resend OTP
  static Future<void> resendOTP({required String phoneNumber}) async {
    await http.post(
      Uri.parse("$baseUrlAuth/resend-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phoneNumber": phoneNumber}),
    );
  }

  // Reset Password after OTP verification
  static Future<String> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneNumber = prefs.getString(
      "phoneNumber",
    ); // Retrieve phone number

    if (phoneNumber == null) {
      throw Exception("Erreur: Aucun numéro de téléphone trouvé.");
    }

    final response = await http.put(
      Uri.parse("$baseUrlAuth/resetPassword"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phoneNumber": phoneNumber, // Send phone number instead of OTP token
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      }),
    );
    final responseBody = jsonDecode(response.body);

     if (response.statusCode == 200) {
      if (responseBody['meta']?['statusCode'] == 1073741824) { // Check the success code from Swagger
        return "Mot de passe réinitialisé avec succès.";
      } else {
        // Check for error messages in the response
        final errorMessage = responseBody['errors'] ?? 
                            responseBody['meta']?['message'] ?? 
                            "Erreur inconnue lors de la réinitialisation du mot de passe";
        throw Exception("Erreur: $errorMessage");
      }
    } else {
      final errorMessage = responseBody['errors'] ?? 
                          responseBody['meta']?['message'] ?? 
                          "Erreur HTTP ${response.statusCode}";
      throw Exception("Erreur: $errorMessage");
    }
  }

  // Function to fetch user details
  static Future<Map<String, dynamic>> getUserDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("authToken");

      if (token == null) {
        print("No token found. Please login.");
        return {
          "success": false,
          "error": "No token found",
          "message": "Please login first",
        };
      }

      final response = await http.get(
        Uri.parse("$baseUrlUser/details"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          "success": true,
          "name": responseData["name"] ?? "",
          "surname": responseData["surname"] ?? "",
          "status": responseData["status"] ?? "",
          "phoneNumber": responseData["phoneNumber"] ?? "",
          "email": responseData["email"] ?? "",
          "cniNumber": responseData["cniNumber"] ?? "",
          "cniExpiration": responseData["cniExpiration"] ?? "",
        };
      } else {
        print("Failed to fetch user details: ${response.body}");
        return {
          "success": false,
          "error": "Server returned ${response.statusCode}",
          "message": "Failed to fetch user details",
        };
      }
    } catch (error) {
      print("Error fetching user details: $error");
      return {
        "success": false,
        "error": error.toString(),
        "message": "Error fetching user details",
      };
    }
  }

  Future<int> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("userId");
    if (userId == null || userId == 0) {
      throw Exception("User ID not found. Please log in again.");
    }
    return userId;
  }

  // Function to update user details
  static Future<bool> updateUserDetails(
    Map<String, dynamic> updatedData,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("authToken");

      if (token == null) {
        print("❌ No token found. Please login.");
        return false;
      }

      final response = await http.put(
        Uri.parse("$baseUrlUser/details"), // Changed endpoint to match your API
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        print("✅ User updated successfully: ${response.body}");
        return true;
      } else {
        print("❌ Failed to update user details: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (error) {
      print("❌ Error updating user details: $error");
      return false;
    }
  }

  // Method to fetch all banks
  static Future<List<Map<String, dynamic>>> getAllBanks() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrlBanks/getAllBank"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        List<dynamic> bankList = responseData["data"] ?? [];

        // Return all bank details as a list of maps
        return bankList
            .whereType<Map<String, dynamic>>()
            .map<Map<String, dynamic>>((bank) => bank)
            .toList();
      } else {
        throw Exception("Failed to fetch banks: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      return []; // Return an empty list instead of null to prevent crashes
    }
  }

  static Future<List<Map<String, String>>> getAllSavings() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrlSavings/getAllSavingTypes"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        List<dynamic> savingList = responseData["data"] ?? [];

        return savingList.map((saving) {
          final bankId = saving['bankId']?.toString();
        
        // Debug print to verify the saving structure
          print('Saving item: ${{
            'bankId': bankId,
            'processingId': saving['processingId'],
            'savingType': saving['savingType'],
          }}');
          return {
            'bankId': saving['bankId'].toString(),
            'savingType': saving['savingType'].toString(),
            'type': saving['savingType'].toString(),
            'description': saving['description'].toString(),
            'amount': saving['amount']?.toString() ?? '0',
            'status': saving['status']?.toString() ?? '',
            'valueDate': saving['valueDate']?.toString() ?? '',
          };
        }).toList();
      } else {
        throw Exception("Failed to fetch savings: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  //method to create a saving
  static Future<Map<String, dynamic>> createSaving({
    required String bankId,
    required String phoneNumber,
    required String savingType,
    required int amount,
    int? goalAmount,
    String? dueDate,
    String? periodicity,
  }) async {
    try {
      print('Attempting to create saving with data:');
      print('bankId: $bankId');
      print('phoneNumber: $phoneNumber');
      print('savingType: $savingType');
      print('amount: $amount');
      print('goalAmount: $goalAmount');
      print('dueDate: $dueDate');
      print('periodicity: $periodicity');

      // Get the authentication token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("authToken");

      if (token == null) {
        return {
          "success": false,
          "message": "Authentication token not found. Please login again.",
        };
      }

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        "bankId": bankId,
        "phoneNumber": phoneNumber,
        "savingType": savingType,
        "amount": amount,
      };

      // Add optional fields if they exist
      if (goalAmount != null) requestBody["goalAmount"] = goalAmount;
      if (dueDate != null) requestBody["dueDate"] = dueDate;
      if (periodicity != null) requestBody["periodicity"] = periodicity;

      // Make the API request
      final response = await http.post(
        Uri.parse("$baseUrlSAVINGSERVICE/createSaving"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(requestBody),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      // Handle the response
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          "success": true,
          "data": responseData,
          "message": "Saving created successfully",
        };
      } else {
        final errorResponse = json.decode(response.body);
        return {
          "success": false,
          "error": errorResponse["message"] ?? "Failed to create saving",
          "statusCode": response.statusCode,
          "details": errorResponse,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
        "message": "An error occurred while creating saving",
      };
    }
  }

  // Method to fetch bank by id
  static Future<Map<String, dynamic>> getBankById(String bankId) async {
    try {
      // Get the authentication token
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Authentication token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrlBanks/$bankId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Debug logging
      print('Bank by ID API Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'] ?? {},
          'meta': responseData['meta'] ?? {
            'statusCode': 0,
            'statusDescription': 'string',
            'message': 'string'
          },
          'paginationDto': responseData['paginationDto'] ?? {
            'count': 0,
            'total': 0
          },
          'error': responseData['error'] ?? {},
        };
      } else {
        return {
          'success': false,
          'data': responseData['data'] ?? {},
          'meta': responseData['meta'] ?? {
            'statusCode': response.statusCode,
            'statusDescription': 'API Error',
            'message': 'Failed to fetch bank details'
          },
          'paginationDto': responseData['paginationDto'] ?? {
            'count': 0,
            'total': 0
          },
          'error': responseData['error'] ?? {
            'code': response.statusCode,
            'message': response.body,
          },
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'An error occurred while fetching bank details',
      };
    }
  }
  
  //method to fetch last saving with phone number
  static Future<Map<String, dynamic>> getLastSaving() async {
    try {
      // Get the stored phone number and auth token
      final prefs = await SharedPreferences.getInstance();
      final String? phoneNumber = prefs.getString('phoneNumber');
      final String? token = prefs.getString('authToken');

      if (phoneNumber == null || phoneNumber.isEmpty) {
        return {
          'success': false,
          'message': 'No phone number found. Please login again.',
        };
      }

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Authentication token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrlSAVINGSERVICE/lastSaving/$phoneNumber'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Debug logging
      print('Last Saving API Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'] ?? {},
          'meta': responseData['meta'] ?? {
            'statusCode': 0,
            'statusDescription': 'string',
            'message': 'string'
          },
          'paginationDto': responseData['paginationDto'] ?? {
            'count': 0,
            'total': 0
          },
          'error': responseData['error'] ?? {},
        };
      } else {
        return {
          'success': false,
          'data': responseData['data'] ?? {},
          'meta': responseData['meta'] ?? {
            'statusCode': response.statusCode,
            'statusDescription': 'API Error',
            'message': 'Failed to fetch last saving'
          },
          'paginationDto': responseData['paginationDto'] ?? {
            'count': 0,
            'total': 0
          },
          'error': responseData['error'] ?? {
            'code': response.statusCode,
            'message': response.body,
          },
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'An error occurred while fetching last saving data',
      };
    }
  }

  static Future<Map<String, dynamic>> doSaving({
    required String amount,
    required String accountId,
    required String internalId,
  }) async {
    try {
      print('Attempting to create a do saving with data:');
      print('Amount: $amount');
      print('AccountId: $accountId');
      print('InternalId: $internalId');

      // Get the authentication token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("authToken");

      if (token == null) {
        return {
          "meta": {
            "statusCode": 401,
            "statusDescription": "Unauthorized",
            "message": "Authentication token not found. Please login again."
          },
          "data": {},
          "paginationDto": {
            "count": 0,
            "total": 0
          },
          "error": {}
        };
      }

      // Prepare the request body correctly
      Map<String, dynamic> requestBody = {
        "amount": amount,
        "accountId": accountId,
        "internalId": internalId,
      };

      // Make the API request
      final response = await http.post(
        Uri.parse("$baseUrlSAVINGSERVICE/doSaving"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(requestBody),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      // Parse the API response
      Map<String, dynamic> responseBody = json.decode(response.body);

      return {
        "meta": {
          "statusCode": response.statusCode,
          "statusDescription": response.statusCode == 200 ? "Success" : "Failed",
          "message": responseBody["message"] ?? "Impossible de réaliser l'opération",
        },
        "data": responseBody["data"] ?? {},
        "paginationDto": responseBody["paginationDto"] ?? {"count": 0, "total": 0},
        "error": responseBody["error"] ?? {}
      };
    } catch (e) {
      return {
        "meta": {
          "statusCode": 500,
          "statusDescription": "Error",
          "message": "Impossible de réaliser l'opération",
        },
        "data": {},
        "paginationDto": {
          "count": 0,
          "total": 0
        },
        "error": {
          "details": e.toString()
        }
      };
    }
  }

  static Future<Map<String, dynamic>> getWithdrawalDetails(String accountId) async {
    final response = await http.get(
      Uri.parse('http://192.168.91.13:18105/api/v1/withdrawa/account/detail/$accountId'),
      headers: {
        'Content-Type': 'application/json',
        // Add any required headers like authorization
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load withdrawal details');
    }
  }

  static Future<Map<String, dynamic>> initWithdraw({
    required String processingId,
    required String accountId,
  }) async {
    final response = await http.post(
      Uri.parse('http://192.168.91.13:18105/api/v1/withdrawa/init'), // Update with your actual endpoint
      headers: {
        'Content-Type': 'application/json',
        // Add any required headers like authorization
      },
      body: json.encode({
        'pricessingId': processingId,
        'accountId': accountId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to initiate withdrawal');
    }
  }

}
