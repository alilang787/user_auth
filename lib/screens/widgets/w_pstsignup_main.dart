import 'dart:io';
import 'package:user_auth/main.dart';
import 'package:user_auth/screens/widgets/w_image_getter.dart';
import 'package:user_auth/screens/widgets/w_loading.dart';
import 'package:user_auth/screens/widgets/w_padText.dart';
import 'package:user_auth/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WPostSignUp extends StatefulWidget {
  final BuildContext ctx;
  const WPostSignUp({super.key, required this.ctx});

  @override
  State<WPostSignUp> createState() => _WPostSignUpState();
}

class _WPostSignUpState extends State<WPostSignUp> {
  bool _isLoading = false;
  File? _profileImage;
  String? _profileImageError;
  String? _firstname;
  String? _lastname;
  String? _date;

  late TextEditingController _dateOfBirthController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _dateOfBirthController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _dateOfBirthController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              IconButton(
                onPressed: () => _onPickImage(context),
                icon: ImageGetter(
                  userImage: _profileImage,
                ),
              ),
              if (_profileImageError != null)
                Text(
                  _profileImageError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              Gap(16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //
                      // ----------- First Name Field --------------

                      paddText(text: 'First Name'),
                      TextFormField(
                        onSaved: (newValue) {
                          _firstname = newValue;
                        },
                        validator: _nameValidator,
                        maxLength: 12,
                        decoration: InputDecoration(
                          errorMaxLines: 3,
                          prefixIcon: Icon(Icons.person),
                          hintText: 'enter your first name',
                        ),
                      ),
                      Gap(2),

                      // ----------- Last Name Field --------------

                      paddText(text: 'Last Name'),
                      TextFormField(
                        onSaved: (newValue) {
                          _lastname = newValue;
                        },
                        validator: _nameValidator,
                        maxLength: 12,
                        decoration: InputDecoration(
                          errorMaxLines: 3,
                          prefixIcon: Icon(Icons.person),
                          hintText: 'enter your last name',
                        ),
                      ),
                      Gap(2),

                      // ----------- DateOfBirth Field --------------

                      paddText(text: 'Date Of Birth'),

                      InkWell(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _showAdaptiveDatePicker(context);
                        },
                        child: TextFormField(
                          controller: _dateOfBirthController,
                          validator: _dobValidator,
                          decoration: InputDecoration(
                            enabled: false,
                            prefixIcon: Icon(Icons.date_range),
                            hintText: 'Date of birth',
                          ),
                        ),
                      ),

                      Gap(22),

                      // ----------- Sign Up Button ------------

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _onSubmit,
                            //  _onSubmit,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Text('Sign Up'),
                            ),
                          )
                        ],
                      ),
                      Gap(26)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading) Loading(),
      ],
    );
  }

  // =================== M E T H O D S ====================

  //      ................  sign up ................
  void _onSubmit() async {
    FocusScope.of(context).unfocus();

    if (_profileImage == null) {
      setState(() {
        _profileImageError = 'Profile Image must be picked!';
      });
    } else
      setState(() {
        _profileImageError = null;
      });
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;
    if (_profileImage == null) {
      return;
    }

    bool error = await Utils.checkConnectivity(context);
    if (error) return;

    setState(() {
      _isLoading = true;
    });

    //  -------- Start Uploading ----------

    final _auth = FirebaseAuth.instance;
    final _storageRef = FirebaseStorage.instance.ref();
    final _imgRef =
        _storageRef.child('ProfileImages/${_auth.currentUser!.uid}.jpg');

    late TaskSnapshot _task;
    try {
      _task =
          await _imgRef.putFile(_profileImage!).timeout(Duration(seconds: 15));
      if (_task.state == TaskState.success) {
        try {
          final _imageUrl = await _imgRef.getDownloadURL();
          if (_imageUrl.isNotEmpty) {
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(_auth.currentUser!.uid)
                  .update({
                'dob': _date,
                'profileUrl': _imageUrl,
                'firstName': _firstname,
                'lastName': _lastname,
              }).timeout(Duration(seconds: 15));
              try {
                await _auth.currentUser!
                    .updateDisplayName('$_firstname $_lastname');
                await _auth.currentUser!.updatePhotoURL(_imageUrl);
              } catch (e) {
                _generalExceptions(context);
                return;
              }
            } catch (e) {
              _generalExceptions(context);
              return;
            }
          }
        } catch (e) {
          _generalExceptions(context);
          return;
        }
      }
    } catch (_) {
      _generalExceptions(context);
      return;
    }

    setState(() {
      _isLoading = false;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('postSignUp', false);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return MainApp();
      },
    ));
  }

  //      ................  image picker ................
  void _onPickImage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 44),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => _pickImage(ImageSource.camera, context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 70,
                      color: Colors.grey,
                    ),
                    Text(
                      'Camera',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery, context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 70,
                      color: Colors.grey,
                    ),
                    Text(
                      'Gallery',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImage(ImageSource source, BuildContext context) async {
    Navigator.pop(context);
    final ImagePicker picker = ImagePicker();
    final _pickedImage = await picker.pickImage(
      source: source,
      // imageQuality: 100,
      maxHeight: 512,
      maxWidth: 512,
    );

    if (_pickedImage != null)
      setState(() {
        _profileImage = File(_pickedImage.path);
      });
    Navigator.pop(context);
  }

  //      ................name validator................
  String? _nameValidator(String? value) {
    if (value == null || value.isEmpty)
      return 'this field can\'t be left empty.';
    final RegExp namePattern = RegExp(
      r'^[A-Za-z][a-z]+$',
    );

    if (!namePattern.hasMatch(value))
      return 'name should consist only letters and only first letter is allowed to be capital ';
    if (value.length < 3) return 'name should consist at least 3 letters';

    return null;
  }

  //    ................date of birth validator................
  String? _dobValidator(String? value) {
    if (value == null || value.isEmpty)
      return 'this field can\'t be left empty.';
    return null;
  }

  //    ..............  show date picker ......................
  void _showAdaptiveDatePicker(BuildContext context) async {
    DateTime? _datetime;
    DateTime _maxDate = DateTime(
      DateTime.now().year - 12,
      DateTime.now().month,
      DateTime.now().day,
    );
    if (Platform.isIOS) {
      await showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            cancelButton: TextButton(
              onPressed: () {
                if (_datetime == null) {
                  _datetime = _maxDate;
                }

                Navigator.pop(context);
              },
              child: Text(
                'Done',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              SizedBox(
                height: 220,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _maxDate,
                  minimumDate: DateTime(1920),
                  maximumDate: _maxDate,
                  onDateTimeChanged: (DateTime newDate) {
                    _datetime = newDate;
                  },
                ),
              )
            ],
          );
        },
      );
    } else {
      _datetime = await showDatePicker(
        context: context,
        firstDate: DateTime(1920),
        lastDate: _maxDate,
      );
    }

    if (_datetime != null) {
      _date = DateFormat.yMd().format(_datetime!);
      setState(() {
        _dateOfBirthController.text = _date!;
      });
    }
  }

  //     ................ firebase exceptions .................
  void _generalExceptions(BuildContext context) {
    setState(() {
      _isLoading = false;
    });

    Utils.showDialog(
      context: context,
      title: 'Something went wrong',
      content: Text('make sure you have working internet connection.'),
    );
    return;
  }
}
