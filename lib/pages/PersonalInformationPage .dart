
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/custom_colors.dart';
import '../service/api_service.dart'; // Ensure this contains your color definitions

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  _PersonalInformationPageState createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {

  bool isEditing = false; // Toggle between edit and view mode
  bool isLoading = true;
  String? errorMessage;

  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cniController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cniExpirationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  // Fetch user details using ApiService
  Future<void> fetchUserDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getUserDetails();

      if (response["success"] == true) {
        setState(() {
          nameController.text = response['name'] ?? '';
          surnameController.text = response['surname'] ?? '';
          phoneController.text = response['phoneNumber'] ?? '';
          cniController.text = response['cniNumber'] ?? '';
          emailController.text = response['email'] ?? '';
          cniExpirationController.text = response['cniExpiration'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response["message"] ?? "Failed to load user details";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: ${e.toString()}";
        isLoading = false;
      });
    }
  }


  

  // Update user details using ApiService
  Future<void> updateUserDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final updatedData = {
        "name": nameController.text,
        "surname": surnameController.text,
        "phoneNumber": phoneController.text,
        "cniNumber": cniController.text,
        "email": emailController.text,
        "cniExpiration": cniExpirationController.text,
      };

      // You'll need to implement this static method in ApiService
      final success = await ApiService.updateUserDetails(updatedData);

      if (success) {
        setState(() {
          isEditing = false;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      } else {
        setState(() {
          errorMessage = "Failed to update profile";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.buttonTextColor,
      appBar: AppBar(
        backgroundColor: CustomColors.buttonTextColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Informations personnelles',
          style: TextStyle(color: CustomColors.primaryColor, fontSize: 18),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: CustomColors.primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isEditing ? Icons.check : FontAwesomeIcons.penToSquare,
                    color: CustomColors.primaryColor,
                  ),
                  onPressed: () {
                    if (isEditing) {
                      updateUserDetails();
                    } else {
                      setState(() => isEditing = true);
                    }
                  },
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Profile Image
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'assets/images/user1.png',
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Editable Fields
                      _buildEditableField(Icons.person_outline, 'Nom', nameController),
                      _buildEditableField(Icons.person_outline, 'Prénom', surnameController),
                      _buildEditableField(Icons.phone_outlined, 'Téléphone', phoneController),
                      _buildEditableField(Icons.email_outlined, 'Email', emailController),
                      _buildEditableField(Icons.credit_card_outlined, 'CNI', cniController),
                      _buildEditableField(Icons.calendar_today_outlined, 'CNI Expiration', cniExpirationController),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEditableField(
      IconData icon, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 14, color: CustomColors.secondaryColor)),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(icon, color: CustomColors.secondaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: isEditing
                  ? TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: label,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: CustomColors.secondaryColor),
                        ),
                      ),
                    )
                  : Text(
                      controller.text.isNotEmpty ? controller.text : "Non renseigné",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
            ),
          ],
        ),
        Divider(height: 20, color: CustomColors.iconBackgroundColor),
      ],
    );
  }
}