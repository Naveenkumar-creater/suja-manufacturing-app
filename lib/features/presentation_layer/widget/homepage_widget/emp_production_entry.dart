// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prominous/constant/lottieLoadingAnimation.dart';
import 'package:prominous/constant/request_data_model/emp_close_shift_model.dart';
import 'package:prominous/constant/request_data_model/productuion_entry_model.dart';
import 'package:prominous/features/presentation_layer/api_services/activity_di.dart';
import 'package:prominous/features/presentation_layer/api_services/emp_production_entry_di.dart';
import 'package:prominous/features/presentation_layer/api_services/employee_di.dart';
import 'package:prominous/features/presentation_layer/api_services/recent_activity.dart';
import 'package:prominous/features/presentation_layer/api_services/target_qty_di.dart';
import 'package:prominous/features/presentation_layer/provider/activity_provider.dart';
import 'package:prominous/features/presentation_layer/provider/asset_barcode_provier.dart';
import 'package:prominous/features/presentation_layer/provider/card_no_provider.dart';
import 'package:prominous/features/presentation_layer/provider/emp_production_entry_provider.dart';
import 'package:prominous/features/presentation_layer/provider/employee_provider.dart';
import 'package:prominous/features/presentation_layer/provider/product_provider.dart';
import 'package:prominous/features/presentation_layer/provider/recent_activity_provider.dart';
import 'package:prominous/features/presentation_layer/provider/shift_status_provider.dart';
import 'package:prominous/features/presentation_layer/provider/target_qty_provider.dart';
import 'package:prominous/features/presentation_layer/widget/emp_production_entry_widget/emp_asset_barcode_scan.dart';
import 'package:prominous/features/presentation_layer/widget/emp_production_entry_widget/emp_cardno_barcode_scanner.dart';
import '../../api_services/product_di.dart';
import '../production_quanties/emp_production_time.dart';
import 'package:intl/intl.dart';
import '../../../../constant/show_pop_error.dart';
import '../../../data/core/api_constant.dart';
import '../../../../constant/utilities/customnum_field.dart';

class EmpProductionEntryPage extends StatefulWidget {
  final int? empid;
  final int? processid;
  final String? barcode;
  final int? cardno;
  final int? assetid;
  final int? shiftId;
  final int? deptid;
  bool? isload;
  final int?attendceStatus;
  final int? psid;

  final String? attenceid;

  EmpProductionEntryPage(
      {Key? key,
      this.empid,
      this.processid,
      this.barcode,
      this.cardno,
      this.assetid,
      this.isload,
      this.shiftId,
      this.deptid,
      this.psid,
      this.attenceid,
       this.attendceStatus})
      : super(key: key);

  @override
  State<EmpProductionEntryPage> createState() => _EmpProductionEntryPageState();
}

class _EmpProductionEntryPageState extends State<EmpProductionEntryPage> {
  final TextEditingController goodQController = TextEditingController();
  final TextEditingController rejectedQController = TextEditingController();
  final TextEditingController reworkQController = TextEditingController();
  final TextEditingController targetQtyController = TextEditingController();
    final TextEditingController batchNOController = TextEditingController();
  final ProductApiService productApiService = ProductApiService();
  final RecentActivityService recentActivityService = RecentActivityService();
  final ActivityService activityService = ActivityService();
  final TargetQtyApiService targetQtyApiService = TargetQtyApiService();

  bool isChecked = false;

  bool isLoading = true;
  late DateTime now;
  late int currentYear;
  late int currentMonth;
  late int currentDay;
  late int currentHour;
  late int currentMinute;
  late String currentTime;
  late int currentSecond; 
  
  String? selectedName;

TimeOfDay timeofDay = TimeOfDay.now();
  late DateTime currentDateTime;
 // Initialized to avoid null check

  List<Map<String, dynamic>> submittedDataList = [];

  String? dropdownProduct;
  String? activityDropdown;
  String? lastUpdatedTime;
    String? currentDate;
  int? reworkValue;
  int? productid;
  int? activityid;
  TimeOfDay? updateTimeManually;
  String? cardNo;
  String? productName;
  String? assetID;

  EmpProductionEntryService empProductionEntryService =
      EmpProductionEntryService();
      
        EmployeeApiService employeeApiService = EmployeeApiService();

  Future<void> updateproduction(int? processid) async {
    final empid = Provider.of<EmployeeProvider>(context, listen: false)
        .user
        ?.listofEmployeeEntity
        ?.first
        .empPersonid;

    final responsedata =
        Provider.of<EmpProductionEntryProvider>(context, listen: false)
            .user
            ?.empProductionEntity;
    final itemid = Provider.of<CardNoProvider>(context, listen: false)
        .user
        ?.scanCardForItem
        ?.pcItemId;
            final assetid = Provider.of<AssetBarcodeProvider>(context, listen: false)
        .user
        ?.scanAseetBarcode
        ?.pamAssetId;

          final pcid = Provider.of<CardNoProvider>(context, listen: false)
        .user
        ?.scanCardForItem
        ?.pcId;
              final Shiftid = Provider.of<ShiftStatusProvider>(context, listen: false)
        .user
        ?.shiftStatusdetailEntity
        ?.psShiftId;
        final ppId = Provider.of<TargetQtyProvider>(context, listen: false)
        .user
        ?.targetQty
        ?.ppid;
        
 DateTime parsedLastUpdatedTime = DateFormat('yyyy-MM-dd HH:mm').parse(lastUpdatedTime!);
    final empproduction = responsedata;
    print(empproduction);
    if (empproduction != null) {
      // Check if empproduction is not empty
      SharedPreferences pref = await SharedPreferences.getInstance();
      String token = pref.getString("client_token") ?? "";

      now = DateTime.now();
      currentYear = now.year;
      currentMonth = now.month;
      currentDay = now.day;
      currentHour = now.hour;
      currentMinute = now.minute;
      currentSecond = now.second;
      final currentDateTime =
          '$currentYear-$currentMonth-$currentDay $currentHour:${currentMinute.toString()}:${currentSecond.toString()}';
      //String toDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      ProductionEntryReqModel requestBody = ProductionEntryReqModel(
        apiFor: "update_production",
        clientAuthToken: token,
        // emppersonid: empid,
        // goodQuantities: empproduction.first.goodqty,
        // rejectedQuantities: empproduction.first.rejqty,
        // reworkQuantities: empproduction.first.ipdflagid,
        ipdRejQty: int.tryParse(rejectedQController.text) ?? 0,
        ipdReworkFlag: reworkValue ?? empproduction.ipdflagid,
        ipdGoodQty: int.tryParse(goodQController.text) ?? 0,
        batchno: int.tryParse(batchNOController.text),
        targetqty: int.tryParse(targetQtyController.text),
        
        ipdCardNo: int.tryParse(cardNo.toString()) ?? empproduction.ipdcardno,


        ipdpaid:  activityid ?? 0,
        ipdFromTime: empproduction.ipdfromtime == ""
            ? currentDateTime.toString()
            : empproduction.ipdfromtime,

        ipdToTime: lastUpdatedTime ?? currentDateTime,
        ipdDate: currentDateTime.toString(),
        ipdId: activityid == empproduction.ipdpaid ?  empproduction.ipdid : 0,
        ipdPcId: pcid??empproduction.ipdpcid,
        ipdDeptId: widget.deptid ?? 1,
        ipdAssetId: assetid ?? 0,
        //ipdcardno: empproduction.first.ipdcardno,
        ipdItemId: itemid ?? empproduction.itemid,
        ipdMpmId: processid,
        emppersonId: widget.empid ?? 0,  
        ipdpsid: widget.psid, 
        ppid:ppId??0 , 
        shiftid: Shiftid,
      );

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
      // Handle response if needed
    } else {
      // Handle case when empproduction is empty
      print("empproduction is empty");
    }
  }

  


    Future<void> empCloseShift() async {
    final process_id = Provider.of<EmployeeProvider>(context, listen: false)
        .user
        ?.listofEmployeeEntity
        ?.first
        .processId;
            final shitId = Provider.of<ShiftStatusProvider>(context, listen: false)
        .user
        ?.shiftStatusdetailEntity?.psShiftId;
                final shiftStatus = Provider.of<ShiftStatusProvider>(context, listen: false)
        .user
        ?.shiftStatusdetailEntity?.psShiftStatus;
          final Shiftid = Provider.of<ShiftStatusProvider>(context, listen: false)
        .user
        ?.shiftStatusdetailEntity
        ?.psShiftId;

     
    final attdid = Provider.of<EmployeeProvider>(context, listen: false)
        .user
        ?.listofEmployeeEntity
        ?.first
        .attendanceid;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("client_token") ?? "";
    DateTime now = DateTime.now();
    //DateTime today = DateTime(now.year, now.month, now.day)
      int dt;

      dt = int.tryParse(widget.attenceid ?? "") ?? 0;

    final requestBody = EmpCloseShift(
        apiFor: "emp_close_shift",
        clientAuthToken: token, 
        psid: widget.psid, 
        attShiftStatus: 2,
        attid: dt ,
        attendenceStatus:widget.attendceStatus, 
       
       );

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
          // loadEmployeeList();
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

  void updateinitial() {
    if (widget.isload == true) {
      final productionEntry =
          Provider.of<EmpProductionEntryProvider>(context, listen: false)
              .user
              ?.empProductionEntity;
      final productname = Provider.of<ProductProvider>(context, listen: false)
          .user
          ?.listofProductEntity;

      setState(() {
        assetID = productionEntry?.ipdassetid?.toString() ?? "0";
        cardNo = productionEntry?.ipdcardno?.toString() ?? "0";

        // If itemid is not 0, find the matching product name
        productName = productionEntry?.itemid != 0
            ? productname
                ?.firstWhere(
                  (product) => productionEntry?.itemid == product.productid,
                )
                ?.productName
            : "0";
      });
    }

 
  }



  @override
  void initState() {
    super.initState();

    // final int? cardStatus= widget.cardno ??0;
    // final int? assetStatus= widget.assetid ??0;

    // Start fetching data and set initial values

    _fetchARecentActivity().then((_) {
      updateinitial();
    });

 currentDateTime = DateTime.now();
    now = DateTime.now();
    currentYear = now.year;
    currentMonth = now.month;
    currentDay = now.day;
    currentHour = now.hour;
    currentMinute = now.minute;
    currentSecond = now.second;
    lastUpdatedTime =
          '$currentYear-$currentMonth-$currentDay $currentHour:${currentMinute.toString()}:${currentSecond.toString()}';
          currentDate='$currentYear-$currentMonth-$currentDay $currentHour:${currentMinute.toString()}:${currentSecond.toString()}';
  }

  @override
  void dispose() {
    
    super.dispose();
    // Dispose text controllers
    targetQtyController.dispose();
    goodQController.dispose();
    rejectedQController.dispose();

  }
    String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  Future<void> _fetchARecentActivity() async {
    try {
      // Fetch data
      await empProductionEntryService.productionentry(
          context: context,
          id: widget.empid ?? 0,
          deptid: widget.deptid ?? 0,
          psid: widget.psid ?? 0);

      await productApiService.productList(
          context: context,
          id: widget.processid ?? 1,
          deptId: widget.deptid ?? 0);

      await recentActivityService.getRecentActivity(
          context: context,
          id: widget.empid ?? 0,
          deptid: widget.deptid ?? 0,
          psid: widget.psid ?? 0);

      await activityService.getActivity(
          context: context,
          id: widget.processid ?? 0,
          deptid: widget.deptid ?? 0);
      final productionEntry =
          Provider.of<EmpProductionEntryProvider>(context, listen: false)
              .user
              ?.empProductionEntity;

      // Access fetched data and set initial values
      final initialValue = productionEntry?.ipdflagid;

      if (initialValue != null) {
        setState(() {
          isChecked = initialValue == 1;
             goodQController.text = productionEntry?.goodqty?.toString() ?? "";
      rejectedQController.text = productionEntry?.rejqty?.toString() ?? "";
      batchNOController.text= productionEntry?.ipdbatchno.toString() ?? ""; // Set isChecked based on initialValue
        });
      }
      // Update cardNo with the retrieved cardNumber
      // setState(() {
      //   cardNo = productionEntry?.ipdcardno?.toString() ??"0"; // Set cardNo with the retrieved value
      // });

      setState(() {
        // Set initial values inside setState
        isLoading = false; // Set isLoading to false when data is fetched
      });
    } catch (e) {
      // Handle errors
      setState(() {
        isLoading = false; // Set isLoading to false even if there's an error
      });
    }
  }

  void _closeShiftPop(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            child: WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Container(
                width: 200,
                height: 150,
               decoration: BoxDecoration( color: Colors.white,borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.only(top:32,),
                  child: Column(children: [
                    const Text("Confirm you submission"),
                    const SizedBox(
                      height: 32,
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                 
                                    await empCloseShift();
                                   await employeeApiService.employeeList(
                            context: context,
                            deptid: widget.deptid ?? 1,
                            processid: widget.processid ?? 0,
                            psid: widget.psid ?? 0);
                                    Navigator.pop(context);
                               
                              } catch (error) {
                                // Handle and show the error message here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error.toString()),
                                    backgroundColor: Colors.amber,
                                  ),
                                );
                              }
                            },
                            child: const Text("Submit"),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Go back")),
                        ],
                      ),
                    )
                  ]),
                ),
              ),
            ),
          );
        });
  }

  void _submitPop(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            child: WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.only(top:32,),
                  child: Column(children: [
                    const Text("Confirm you submission"),
                    const SizedBox(
                      height: 32,
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                if (dropdownProduct != null &&
                                        dropdownProduct != 'Select' &&
                                        goodQController.text.isNotEmpty ||
                                    rejectedQController.text.isNotEmpty ||
                                    reworkQController.text.isNotEmpty) {
                             
                                   await updateproduction(widget.processid);
                                   await _fetchARecentActivity();
                                    Navigator.pop(context);
                                  
                                }
                              } catch (error) {
                                // Handle and show the error message here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error.toString()),
                                    backgroundColor: Colors.amber,
                                  ),
                                );
                              }
                            },
                            child: const Text("Submit"),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Go back")),
                        ],
                      ),
                    )
                  ]),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final productionEntry =
        Provider.of<EmpProductionEntryProvider>(context, listen: false)
            .user
            ?.empProductionEntity;
            

    final recentActivity =
        Provider.of<RecentActivityProvider>(context, listen: false)
            .user
            ?.recentActivitesEntityList;
    print(productionEntry);
    final fromtime = productionEntry?.ipdfromtime =="" ?currentDate:productionEntry?.ipdfromtime;

    final productname = Provider.of<ProductProvider>(context, listen: false)
        .user
        ?.listofProductEntity;

    final activity = Provider.of<ActivityProvider>(context, listen: false)
        .user
        ?.activityEntity;

    final activityName =
        activity?.map((process) => process.paActivityName)?.toSet()?.toList() ??
            [];

    final ProductNames =
        productname?.map((process) => process.productName)?.toSet()?.toList() ??
            [];
    final asset = Provider.of<AssetBarcodeProvider>(context, listen: false)
        .user
        ?.scanAseetBarcode;

    final cardNumber = Provider.of<CardNoProvider>(context, listen: false)
        .user
        ?.scanCardForItem;
       

    final processName = Provider.of<EmployeeProvider>(context, listen: false)
        .user
        ?.listofEmployeeEntity?.first.processName ?? "";
    // Set cardNo with the retrieved value

    // Update cardNo with the retrieved cardNumber

    // Assuming 1 means true // Assuming ipdid is an int

// final matchingProduct = productname?.firstWhere(
//   (product) => product.productid == (productionEntry?.ipdid ?? 0),

// );
// if (matchingProduct != null) {
//   dropdownProduct = matchingProduct.productName;
// }

    return isLoading
        ? Scaffold(
            body: Center(
              child: LottieLoadingAnimation(),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.grey.shade300,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.arrow_back)),
                          Text(
                            '${processName}',
                            style: TextStyle(
                                color: const Color.fromARGB(255, 51, 43, 43)),
                          ),
                        ],
                      ),
                      Container(
                        height: 660,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: 300,
                                      height: 300,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                                8),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.all(
                                                8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                      'From Time :'),
                                                  SizedBox(
                                                    width: 16,
                                                  ),
                                                  Text(
                                                      '${fromtime}'),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                      'End Time :'),
                                                  SizedBox(
                                                    width: 16,
                                                  ),
                                                  Text(
                                                      '${lastUpdatedTime}'),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: UpdateTime(
                                                onTimeChanged:
                                                    (time) {
                                                  setState(() {
                                                    lastUpdatedTime =
                                                        time.toString(); // Update the manually set time
                                                  });
                                                },
                                              ),
                                            ),
                                            Expanded(child: Text("")),
                                             Expanded(child: Text(""))
                              
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: 300,
                                      height: 300,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                                8),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.all(
                                                8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                             Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                      'Batch No               :'),
                                                  SizedBox(
                                                    width: 16,
                                                  ),
                                                  SizedBox(
                                                    width: 180,
                                  
                                                    child:
                                                        CustomNumField(
                                                      controller:
                                                          batchNOController,
                                                      hintText:
                                                          'Batch No  ',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text('Card NO '),
                                                  CardNoScanner(
                                                    empId: widget
                                                        .empid,
                                                    processId: widget
                                                        .processid,
                                                    shiftId: widget
                                                        .shiftId,
                                                    onCardDataReceived:
                                                        (scannedCardNo,
                                                            scannedProductName) {
                                                      setState(() {
                                                        cardNo =
                                                            scannedCardNo;
                                                        productName =
                                                            scannedProductName;
                                                      });
                                                    },
                                                  ),
                                                  SizedBox(
                                                      width: 16),
                                                  Text(':'),
                                                  SizedBox(
                                                      width: 8),
                                                  Text(
                                                      '  ${cardNo}' ??
                                                          "0"),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(
                                                      "prominous Ref                :     ${productName}" ??
                                                          "0"),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                      'Activity                  :'),
                                                  SizedBox(
                                                      width: 18),
                                                  // DropdownButton<String?>(
                                                  //     items: ProductNames,
                                                  //     onChanged: onChanged)
                                                  Container(
                                                    width: 150,
                                                    height: 40,
                                                    decoration:
                                                        BoxDecoration(
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Colors
                                                              .grey),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                    ),
                                                    child:
                                                        DropdownButton<
                                                            String>(
                                                      value:
                                                          activityDropdown,
                                                          
                              
                                                      hint: Text(
                                                          "Select"), // Default value is 'Select'
                                                      underline:
                                                          Container(
                                                        height: 5,
                                                      ),
                                                      isExpanded:
                                                          true,
                                                      onChanged:
                                                          (String?
                                                              newvalue) async{
                                                        setState(
                                                            () {
                                                          activityDropdown =
                                                              newvalue;
                                                                  });
                                                          // Set the productid only if newvalue is not null
                                                          if (newvalue !=
                                                              null) {
                                                            activityid = activity!
                                                                .firstWhere((product) =>
                                                                    product.paActivityName ==
                                                                    newvalue)
                                                                ?.paId;
                                                            final itemid = Provider.of<CardNoProvider>(context,
                                                                    listen: false)
                                                                .user
                                                                ?.scanCardForItem
                                                                ?.pcItemId;
                              
                                                          await targetQtyApiService.getTargetQty(
                                                                context:
                                                                    context,
                                                                paId: activityid ??
                                                                    0,
                                                                deptid: widget.deptid ??
                                                                    1,
                                                              
                                                                psid:
                                                                    widget.psid ?? 0, empid: widget.empid ?? 0 );
                                                                                         final targetqty = Provider.of<TargetQtyProvider>(context, listen: false)
          .user
          ?.targetQty
          ?.targetqty;  
                              setState(() {
                                  targetQtyController.text = targetqty.toString(); 
                              });
                                                                   
                                                    
                                                 
                                                          } else {
                                                            productid =
                                                                null;
                                                          }
                                                    
                                                      },
                                                      items: activityName
                                                              ?.map(
                                                                  (activityName) {
                                                            return DropdownMenuItem<
                                                                String>(onTap:(){
                                                                  setState(() {
                                                                    selectedName=activityName;
                                                                  });
                                                                } ,
                                                              value:
                                                                  activityName,
                                                              child:
                                                                  Text(
                                                                activityName ??
                                                                    "",
                                                                style:
                                                                    TextStyle(color: Colors.black),
                                                              ),
                                                            );
                                                          }).toList() ??
                                                          [], // Add toList() to avoid null error
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text('Asset Id'),
                                                  SizedBox(
                                                      width: 8),
                                                  ScanBarcode(
                                                    empId: widget
                                                        .empid,
                                                    processId: widget
                                                        .processid,
                                                    shiftId: widget
                                                        .shiftId,
                                                    onCardDataReceived:
                                                        (scannedAssetId) {
                                                      setState(() {
                                                        assetID =
                                                            scannedAssetId;
                                                      });
                                                    },
                                                  ),
                                                  SizedBox(
                                                      width: 10),
                                                  Text(':'),
                                                  SizedBox(
                                                      width: 15),
                                                  Text(
                                                      '${assetID}' ??
                                                          "1"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: 300,
                                      height: 300,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                                8),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.all(
                                                8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                      'Good Qty        :'),
                                                  SizedBox(
                                                    width: 16,
                                                  ),
                                                  SizedBox(
                                                    width: 180,
                                                    height: 100,
                                                    child:
                                                        CustomNumField(
                                                      controller:
                                                          goodQController,
                                                      hintText:
                                                          'Good Quantity',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                      'Rejected Qty   :'),
                                                  SizedBox(
                                                    width: 16,
                                                  ),
                                                  SizedBox(
                                                    width: 180,
                                                    height: 100,
                                                    child:
                                                        CustomNumField(
                                                      controller:
                                                          rejectedQController,
                                                      hintText:
                                                          'Rejected Quantity',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height:20),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                      'Target Qty       :'),
                                                  SizedBox(
                                                    width: 16,
                                                  ),
                                                    SizedBox(
                                                      width: 180,
                                                      height: 100,
                                                      child:
                                                          CustomNumField(
                                                        controller:
                                                            targetQtyController,
                                                        hintText:
                                                            'Target Quantity',
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                      'Rework            :'),
                                                  SizedBox(
                                                    width: 60,
                                                    height: 40,
                                                    child: Checkbox(
                                                      value:
                                                          isChecked,
                                                      activeColor:
                                                          Colors
                                                              .green,
                                                      onChanged:
                                                          (newValue) {
                                                        setState(
                                                            () {
                                                          isChecked =
                                                              newValue ??
                                                                  false;
                                                          reworkValue =
                                                              isChecked
                                                                  ? 1
                                                                  : 0;
                                                        });
                                                        print(
                                                            "reworkvalue  ${reworkValue}");
                                                        // Perform any additional actions here, such as updating the database
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                                child: Text(''))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: selectedName!=null?() {
                                      _submitPop(context);
                                    }:null,
                                    child: Text('Submit'),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _closeShiftPop(context);
                                    },
                                    child: Text('Close Shift'),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recent Activities',
                                    style: TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              (recentActivity != null &&
                                      recentActivity.isNotEmpty)
                                  ? Column(
                                      children: [
                                        Container(
                                          height: 80,
                                          width: double.infinity,
                                          decoration: const BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.only(
                                                      topLeft: Radius
                                                          .circular(8),
                                                      topRight: Radius
                                                          .circular(8)),
                                              color: Color.fromARGB(
                                                  255, 45, 54, 104)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                            children: [
                                              Container(
                                                alignment:
                                                    Alignment.center,
                                                width: 100,
                                                child: Text('S.NO',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .white)),
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.center,
                                                width: 200,
                                                child: Text('Prev Time',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .white)),
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.center,
                                                width: 200,
                                                child: Text(
                                                    'Product Name',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .white)),
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.center,
                                                width: 200,
                                                child: Text('Good Qty',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .white)),
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.center,
                                                width: 200,
                                                child: Text(
                                                    'Rejected Qty',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .white)),
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.center,
                                                width: 200,
                                                child: Text('Rework ',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .white)),
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.center,
                                                width: 100,
                                                child: Text(
                                                    'Edit Entries',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .white)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.only(
                                                      bottomLeft: Radius
                                                          .circular(8),
                                                      bottomRight:
                                                          Radius
                                                              .circular(
                                                                  8))),
                                          width: double.infinity,
                                          height: 160,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount:
                                                recentActivity?.length,
                                            itemBuilder:
                                                (context, index) {
                                              final data =
                                                  recentActivity?[
                                                      index];
                                              return Container(
                                                decoration:
                                                    BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          width: 1,
                                                          color: Colors
                                                              .grey
                                                              .shade300)),
                                                  color: index % 2 == 0
                                                      ? Colors
                                                          .grey.shade50
                                                      : Colors.grey
                                                          .shade100,
                                                ),
                                                height: 80,
                                                width: double.infinity,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                  children: [
                                                    Container(
                                                      alignment:
                                                          Alignment
                                                              .center,
                                                      width: 100,
                                                      child: Text(
                                                        ' ${index + 1}  ',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey
                                                                .shade700),
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment
                                                              .center,
                                                      width: 200,
                                                      child: Text(
                                                        ' ${data?.ipdtotime ?? ''}  ',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey
                                                                .shade700),
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment
                                                              .center,
                                                      width: 200,
                                                      child: Text(
                                                        ' ${data?.ipditemid ?? ''}  ',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey
                                                                .shade700),
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment
                                                              .center,
                                                      width: 200,
                                                      child: Text(
                                                        '  ${data?.ipdgoodqty ?? ''} ',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey
                                                                .shade700),
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment
                                                              .center,
                                                      width: 200,
                                                      child: Text(
                                                        '  ${data?.ipdrejqty ?? ''}',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey
                                                                .shade700),
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment
                                                              .center,
                                                      width: 200,
                                                     
                                                      child: Text(
                                                        '  ${data?.ipdreworkflag ?? ''} ',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey
                                                                .shade700),
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment
                                                              .center,
                                                      width: 100,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          // updateproduction(
                                                          //     widget
                                                          //         .processid);
                                                        },
                                                        icon: const Icon(
                                                            Icons.edit,
                                                            size: 20,
                                                            color: Colors
                                                                .blue),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Text("No data available"),
                                    ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
