import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:team_clone/constants.dart';
import '../Login/AfterLogin/Profile.dart';

class ProfilePic extends StatefulWidget {
  final File image;
  ProfilePic({required this.image});

  @override
  _ProfilePicState createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  var _isLoading = false;
  final picker = ImagePicker();
  var progress;

  Future<Null> _cropImage() async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedImage!.path,
        cropStyle: CropStyle.circle,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
              ]
            : [
                CropAspectRatioPreset.square,
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            toolbarColor: dark),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image',
        ));
    if (croppedFile != null) {
      setState(() {
        pickedImage = croppedFile;
      });
    }
  }

  @override
  void initState() {
    pickedImage = widget.image;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Preview',style: GoogleFonts.montserrat()),
        elevation: 4,
      ),
      body: ProgressHUD(
        indicatorColor: isDark ? Colors.white : light,
        backgroundColor: Colors.transparent,
        borderColor: Colors.transparent,
        child: Builder(builder: (context) {
          progress = ProgressHUD.of(context);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildProfilePic(),
                _isLoading
                    ? CircularProgressIndicator()
                    : FlatButton(
                        onPressed: _cropImage,
                        child: Text(
                          'CROP PHOTO',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            color: Theme.of(context).buttonColor,
                          ),
                        ),
                      ),
                FlatButton(
                  onPressed: () async {
                    setState(() {
                      Navigator.of(context).pop();
                    });
                  },
                  child: Text(
                    'UPLOAD PHOTO',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Theme.of(context).buttonColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfilePic() {
    return Center(
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(4.6),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  offset: Offset(1, 1),
                  blurRadius: 12,
                  spreadRadius: 2,
                  color: dark.withOpacity(0.40),
                ),
              ],
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: CircleAvatar(
                radius: 100,
                backgroundImage: FileImage(pickedImage!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
