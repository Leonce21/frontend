
import 'package:epargne_plus/pages/PersonalInformationPage%20.dart';
import 'package:flutter/material.dart';
import '../components/custom_colors.dart';
import '../service/api_service.dart';
import 'NotificationsPage.dart';
import 'WithdrawPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String fullName = "Chargement..."; // Default loading text
  String status = "Chargement...";
  

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    var response = await ApiService.getUserDetails();

    if (response["success"] == false) {
      // Handle error case
      print("Error fetching user details: ${response["error"]}");
      setState(() {
        fullName = "Failed to load data";
        status = "";
      });
    } else {
      // Process the user details
      setState(() {
        fullName = "${response['name']} ${response['surname']}";
        status = response['status'] ?? '';
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
          'Profile',
          style: TextStyle(
            color: CustomColors.primaryColor,
            fontSize: 18,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF4F4F4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: CustomColors.primaryColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // Profile Section (Profile picture on the left, name and role on the right)
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(35), // Rounded image
                  child: Image.asset(
                    'assets/images/user1.png', // Update with actual image path
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 15), // Space between image and text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      status.isNotEmpty ? status : "Non défini",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildListTile(
              context,
              Icons.account_circle_outlined,
              'Informations personnelles',
            ),
            // _buildListTileWithBadge(
            //   context,
            //   Icons.notifications_none_rounded,
            //   'Notifications',
            //   '3',
            // ),
            // _buildListTileWithdraw(
            //   context,
            //   Icons.notifications_none_rounded,
            //   'Retrait',
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navigate to Informations personnelles page when the 'Informations personnelles tile is tapped
              if (title == 'Informations personnelles') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalInformationPage(),
                  ),
                );
              }
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: ListTile(
              leading: Icon(icon, color: CustomColors.secondaryColor),
              title: Text(title, style: TextStyle(fontSize: 16)),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Divider(height: 1, color: CustomColors.iconBackgroundColor),
      ],
    );
  }

  Widget _buildListTileWithBadge(
    BuildContext context,
    IconData icon,
    String title,
    String badge,
  ) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navigate to Notifications page when the 'Notifications tile is tapped
              if (title == 'Notifications') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              }
              
              
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: ListTile(
              leading: Icon(icon, color: CustomColors.secondaryColor),
              title: Text(title, style: TextStyle(fontSize: 16)),
              trailing: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),

        Divider(height: 1, color: CustomColors.iconBackgroundColor),
      ],
    );
  }

  Widget _buildListTileWithdraw(BuildContext context, IconData icon, String title) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
             
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: ListTile(
              leading: Icon(icon, color: CustomColors.secondaryColor),
              title: Text(title, style: TextStyle(fontSize: 16)),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Divider(height: 1, color: CustomColors.iconBackgroundColor),
      ],
    );
  }
}
