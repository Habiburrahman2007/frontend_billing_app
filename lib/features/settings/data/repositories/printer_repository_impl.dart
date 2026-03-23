import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/printer_helper.dart';
import '../../domain/repositories/printer_repository.dart';

class PrinterRepositoryImpl implements PrinterRepository {
  final SharedPreferences sharedPreferences;
  final PrinterHelper _printerHelper = PrinterHelper();

  PrinterRepositoryImpl(this.sharedPreferences);

  @override
  Future<List<BluetoothInfo>> scanDevices() async {
    if (await _printerHelper.checkPermission()) {
      return await _printerHelper.getBondedDevices();
    }
    throw Exception('Bluetooth permission denied');
  }

  @override
  Future<bool> connect(String macAddress) async {
    return await _printerHelper.connect(macAddress);
  }

  @override
  Future<bool> disconnect() async {
    return await _printerHelper.disconnect();
  }

  @override
  String? getSavedPrinterMac() {
    return sharedPreferences.getString('printer_mac');
  }

  @override
  String? getSavedPrinterName() {
    return sharedPreferences.getString('printer_name');
  }

  @override
  Future<void> savePrinterData(String mac, String name) async {
    await sharedPreferences.setString('printer_mac', mac);
    await sharedPreferences.setString('printer_name', name);
  }

  @override
  Future<void> clearPrinterData() async {
    await sharedPreferences.remove('printer_mac');
    await sharedPreferences.remove('printer_name');
  }

  @override
  Future<void> testPrint(String shopName) async {
    await _printerHelper
        .printText("Test Print\n\n$shopName\n\n----------------\n\n");
  }
}
