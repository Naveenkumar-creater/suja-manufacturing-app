import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suja/features/presentation_layer/api_services/allocatio_di.dart';
import 'package:suja/features/domain/entity/AllocationEntity.dart';
import 'package:suja/features/presentation_layer/api_services/employee_di.dart';
import 'package:suja/features/presentation_layer/provider/allocation_provider.dart';
import 'package:http/http.dart' as http;
import '../../../../constant/request_model.dart';
import '../../../../constant/show_pop_error.dart';
import '../../../data/core/api_constant.dart';
import '../../api_services/process_di.dart';
import 'employee_details_list.dart';

class EmployeeAllocationPopup extends StatefulWidget {
  final int? empId;
  final int? mfgpempid;
  final int? processid;
  final int? shiftid;

  EmployeeAllocationPopup({
    required this.empId,
    required this.mfgpempid,
    required this.processid,
    required this.shiftid
  });

  @override
  _EmployeeAllocationPopupState createState() =>
      _EmployeeAllocationPopupState();
}

class _EmployeeAllocationPopupState extends State<EmployeeAllocationPopup> {
  String? selectedItem;
  int? selectedProcessId;
  AllocationService allocationService = AllocationService();
  EmployeeApiService employeeApiService = EmployeeApiService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllocationList();
    // employeeApiService.employeeList(context: context, id: widget.processid!, shiftid: widget.shiftid);
  }

  Future<void> _fetchAllocationList() async {
    try {
      await allocationService.changeallocation(
          context: context, id: widget.empId??0);
      setState(() {
        isLoading = true; // Set isLoading to false when data is fetched
      });
    } catch (e) {
      // ignore: avoid_print
      // print('Error fetching asset list: $e');
      setState(() {
        isLoading = false; // Set isLoading to false even if there's an error
      });
    }
  }

  Future<void> sendProcess() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("client_token") ?? "";
    DateTime now = DateTime.now();

    final requestBody = ApiRequestDataModel(
        apiFor: "change_process",
        clientAuthToken: token,
        mfgPmpmId: selectedProcessId,
        mfgPersonId: widget.empId,
        mfgpEmpId: widget.mfgpempid);
    final requestBodyjson = jsonEncode(requestBody.toJson());

    print(requestBodyjson);

    const timeoutDuration = Duration(seconds: 30);
    try {
      http.Response response = await http
          .post(
            Uri.parse(ApiConstant.baseUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: requestBodyjson,
          )
          .timeout(timeoutDuration);

      // ignore: avoid_print
      print(response.body);

      if (response.statusCode == 200) {
        try {
          final responseJson = jsonDecode(response.body);
          print(responseJson);
          return responseJson;
        } catch (e) {
          // Handle the case where the response body is not a valid JSON object
          throw ("Invalid JSON response from the server");
        }
      } else {
        throw ("Server responded with status code ${response.statusCode}");
      }
    } on TimeoutException {
      throw ('Connection timed out. Please check your internet connection.');
    } catch (e) {
      ShowError.showAlert(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final productResponse =
        Provider.of<AllocationProvider>(context, listen: true)
            .User
            ?.allocationEntity;

    // Convert the list to a set to remove duplicates, then back to list
    final ProcessNames = productResponse
            ?.map((process) => process.processname)
            ?.toSet()
            ?.toList() ??
        [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text(
            //       "Process :",
            //       style: TextStyle(color: Colors.black, fontSize: 25),
            //     ),
            //     SizedBox(
            //       width: 10,
            //       height: 80,
            //     ),
            //     Expanded(
            //       child: SizedBox(
            //         // Wrap the DropdownButton with a fixed size container
            //         height: 50, // Set a fixed height for the dropdown list
            //         child: Row(
            //           // Use ListView for vertical scrolling
            //           children: [
            //             DropdownButton<String>(
            //               icon: Icon(Icons.arrow_drop_down,
            //                   color: Colors.blue, size: 45),
            //               // Set dropdownColor to transparent to hide dropdown color
            //               // hint: Text(
            //               //   'Select Process',
            //               //   style: TextStyle(
            //               //       color: Colors
            //               //           .black26), // Set dropdown text color to black
            //               // ),
            //               value: selectedItem,
            //               underline: Container(
            //                 height: 2,
            //               ),
            //               onChanged: (String? newValue) {
            //                 setState(() {
            //                   selectedItem = newValue;
            //                   selectedProcessId = productResponse
            //                       ?.firstWhere((process) =>
            //                           process.processname == newValue)
            //                       ?.processid;
            //                 });
            //               },

            //               // Redirect to the previous screen
            //               //Navigator.pop(context, newValue);

            //               items: ProcessNames?.map((name) {
            //                     return DropdownMenuItem<String>(
            //                       value: name,
            //                       child: Text(name ?? "",
            //                           style: TextStyle(
            //                               color: Colors
            //                                   .black)), // Set dropdown text color to black
            //                     );
            //                   }).toList() ??
            //                   [], // Add toList() to avoid null error
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
              ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'P R O C E S S',
                // style: drawerTextColor,
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 350,
                child: ListView.builder(
                  itemCount: productResponse?.length ?? 0,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        leading: Text(''),
                        title: Text(
                          productResponse![index].processname ?? "",
                          style: TextStyle(color: Colors.blue),
                        ),
                                   onTap: () async {
                      final processId = productResponse[index].processid ?? 0;
                      if (processId != null) {
                        setState(() {
                           selectedProcessId = productResponse
                                        ?.firstWhere((process) =>
                                            process.processid == processId)
                                        ?.processid;
                                  });
                        
                        await sendProcess();
                    
                        await employeeApiService.employeeList(
                          context: context, 
                          id: widget.processid!,
                          shiftid: widget.shiftid??1
                        );
                        
                        Navigator.of(context).pop();
                      }
                    },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // SizedBox(
            //   height: 200,
            //   width: 500,
            // ),

           
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.only(left: 150),
            //       child: ElevatedButton(
            //         style: ButtonStyle(
            //           backgroundColor:
            //               MaterialStateProperty.all<Color>(Colors.blue),
            //         ),
            //         autofocus: true,
            //         onPressed: () async{
                    
            //             await sendProcess();
            //              await  employeeApiService.employeeList(
            //                   context: context, id: widget.processid!);
                       
            //               Navigator.of(context).pop();
                        
             
            //         },
            //         child: const Text(
            //           'Ok',
            //           style: TextStyle(
            //             color: Colors.black,
            //             fontSize: 15,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
