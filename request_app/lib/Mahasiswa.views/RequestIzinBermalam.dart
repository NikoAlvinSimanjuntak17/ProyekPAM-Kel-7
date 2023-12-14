import 'package:flutter/material.dart';
import 'package:it_del/Mahasiswa.views/FormIzinBermalam.dart';
import 'package:it_del/Mahasiswa.views/MahasiswaScreen.dart';
import 'package:it_del/Models/api_response.dart';
import 'package:it_del/Models/request_izin_bermalam.dart';
import 'package:it_del/Auth/login_screen.dart';
import 'package:it_del/Services/IzinBermalam_service.dart';
import 'package:it_del/Services/globals.dart';
import 'package:it_del/Services/User_service.dart';

class RequestIzinBermalamScreen extends StatefulWidget {
  @override
  _RequestIzinBermalamScreenState createState() =>
      _RequestIzinBermalamScreenState();
}

class _RequestIzinBermalamScreenState extends State<RequestIzinBermalamScreen> {
  List<dynamic> _izinbermalamlist = [];
  int userId = 0;
  bool _loading = true;

  Future<void> retrievePosts() async {
    try {
      userId = await getUserId();
      ApiResponse response = await getIzinBermalam();

      if (response.error == null) {
        setState(() {
          _izinbermalamlist = response.data as List<dynamic>;
          _loading = _loading ? !_loading : _loading;
        });
      } else if (response.error == unauthrorized) {
        logout().then((value) => {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              )
            });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}'),
        ));
      }
    } catch (e) {
      print("Error in retrievePosts: $e");
    }
  }

  void _navigateToAddData() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FormIzinBermalams(
              title: 'Request Izin Bermalam',
            )));
  }

  void deleteIzinBermalam(int id) async {
    try {
      ApiResponse response = await DeleteIzinBermalam(id);

      if (response.error == null) {
        await Future.delayed(Duration(milliseconds: 300)); // Add this line
        Navigator.pop(context); // Close the confirmation dialog
        retrievePosts(); // Move retrievePosts after the dialog is closed
      } else if (response.error == unauthrorized) {
        // ... (unchanged)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}'),
        ));
      }
    } catch (e) {
      print("Error in deleteIzinBermalam: $e");
    }
  }

  @override
  void initState() {
    // Call retrievePosts to fetch data when the screen is initialized
    retrievePosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _loading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('No')),
                    DataColumn(label: Text('Keperluan IB')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _izinbermalamlist
                      .map(
                        (requestIzinBermalam) => DataRow(
                          cells: [
                            DataCell(Text(
                                '${_izinbermalamlist.indexOf(requestIzinBermalam) + 1}')),
                            DataCell(Text(requestIzinBermalam.reason)),
                            DataCell(Text(requestIzinBermalam
                                .status)), // Replace with actual status property
                            DataCell(
                              PopupMenuButton(
                                itemBuilder: (BuildContext context) {
                                  return [
                                    PopupMenuItem(
                                      child: Text('Edit'),
                                      value: 'edit',
                                    ),
                                    PopupMenuItem(
                                      child: Text('View'),
                                      value: 'view',
                                    ),
                                    PopupMenuItem(
                                      child: Text('Cancel'),
                                      value: 'delete',
                                    ),
                                  ];
                                },
                                onSelected: (String value) {
                                  if (value == 'edit') {
                                    int index = _izinbermalamlist
                                        .indexOf(requestIzinBermalam);
                                    RequestIzinBermalam selectedIzinBermalam =
                                        _izinbermalamlist[index];

                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => FormIzinBermalams(
                                        title: "Edit Izin Bermalam",
                                        formIzinBermalam: selectedIzinBermalam,
                                      ),
                                    ));
                                  } else if (value == 'view') {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("View Izin Bermalam"),
                                          content: Text(
                                              "Keperluan IB: ${requestIzinBermalam.reason}"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Close'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else if (value == 'delete') {
                                    int index = _izinbermalamlist
                                        .indexOf(requestIzinBermalam);
                                    RequestIzinBermalam selectedIzinBermalam =
                                        _izinbermalamlist[index];
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Delete Izin Bermalam"),
                                          content: Text(
                                              "Apakah Anda yakin ingin menghapus izin bermalam ini?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                    context); // Tutup dialog konfirmasi
                                              },
                                              child: Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteIzinBermalam(
                                                    selectedIzinBermalam.id ??
                                                        0);
                                              },
                                              child: Text('Hapus'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _navigateToAddData,
          label: Text('Request Here'),
          icon: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => MahasiswaScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    '<-  Back to Home',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
