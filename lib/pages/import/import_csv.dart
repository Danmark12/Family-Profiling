// lib/services/import_csv_service.dart
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../../db/config.dart';
import '../../models/household.dart';

class ImportBarangayCSV {
  static Future<ImportResult> import({
    required int userId,
    required String barangay,
  }) async {
    
    // 1. Pick CSV file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      dialogTitle: 'Select CSV file to import',
    );
    
    if (result == null) {
      return ImportResult(success: false, message: 'No file selected');
    }
    
    // 2. Read and parse CSV
    final file = File(result.files.single.path!);
    final csvData = await file.readAsString();
    List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);
    
    if (rows.length < 3) {
      return ImportResult(success: false, message: 'Invalid file format. File must contain headers and data rows.');
    }
    
    // 3. Find the header row
    int headerRowIndex = -1;
    for (int i = 0; i < rows.length; i++) {
      if (rows[i].isNotEmpty && 
          (rows[i][0].toString().toLowerCase().contains('hh') || 
           rows[i][0].toString().toLowerCase().contains('household'))) {
        headerRowIndex = i;
        break;
      }
    }
    
    if (headerRowIndex == -1) {
      return ImportResult(success: false, message: 'Could not find header row in CSV file.');
    }
    
    // Get headers
    final headers = rows[headerRowIndex].map((h) => h.toString().trim().toLowerCase()).toList();
    
    // 4. Get last household number for this user
    int? lastHouseholdNo = await DBHelper.instance.getLastHouseholdNoByUser(userId);
    int nextHouseholdNo = (lastHouseholdNo ?? 0) + 1;
    
    int importedCount = 0;
    int errorCount = 0;
    int skippedCount = 0;
    List<String> errors = [];
    
    // 5. Process data rows (start after header row)
    for (int i = headerRowIndex + 1; i < rows.length; i++) {
      final row = rows[i];
      
      // ============ SKIP EMPTY ROWS ============
      // Skip if row is empty or null
      if (row.isEmpty) {
        skippedCount++;
        continue;
      }
      
      // Skip if all cells are empty, null, or just whitespace
      bool allEmpty = row.every((cell) {
        if (cell == null) return true;
        String strValue = cell.toString().trim();
        return strValue.isEmpty || strValue == "-" || strValue == "null";
      });
      
      if (allEmpty) {
        skippedCount++;
        continue;
      }
      
      // Skip summary rows (rows that contain totals or statistics)
      if (row.length > 0 && row[0] != null) {
        String firstCell = row[0].toString().toLowerCase().trim();
        if (firstCell.contains('total') || 
            firstCell.contains('summary') ||
            firstCell.contains('generated') ||
            firstCell == 'barangay:' ||
            firstCell == 'zone:') {
          skippedCount++;
          continue;
        }
      }
      
      // ============ CHECK IF THIS IS A VALID HOUSEHOLD ROW ============
      // A valid household should at least have a household number or zone
      bool hasValidData = false;
      
      // Check for household number
      int householdNoIndex = headers.indexOf('hh');
      if (householdNoIndex == -1) {
        householdNoIndex = headers.indexOf('household no');
      }
      if (householdNoIndex == -1) {
        householdNoIndex = headers.indexOf('hh no');
      }
      
      if (householdNoIndex != -1 && householdNoIndex < row.length) {
        String hhValue = row[householdNoIndex].toString().trim();
        if (hhValue.isNotEmpty && hhValue != '-' && hhValue != 'null' && int.tryParse(hhValue) != null) {
          hasValidData = true;
        }
      }
      
      // Check zone if household number not found
      int zoneIndex = headers.indexOf('zone');
      if (!hasValidData && zoneIndex != -1 && zoneIndex < row.length) {
        String zoneValue = row[zoneIndex].toString().trim();
        if (zoneValue.isNotEmpty && zoneValue != '-' && zoneValue != 'null') {
          hasValidData = true;
        }
      }
      
      // Check father or mother name
      int fatherIndex = headers.indexOf('father name');
      int motherIndex = headers.indexOf('mother name');
      
      if (!hasValidData && fatherIndex != -1 && fatherIndex < row.length) {
        String fatherValue = row[fatherIndex].toString().trim();
        if (fatherValue.isNotEmpty && fatherValue != '-') {
          hasValidData = true;
        }
      }
      
      if (!hasValidData && motherIndex != -1 && motherIndex < row.length) {
        String motherValue = row[motherIndex].toString().trim();
        if (motherValue.isNotEmpty && motherValue != '-') {
          hasValidData = true;
        }
      }
      
      // Skip if no valid data found in this row
      if (!hasValidData) {
        skippedCount++;
        continue;
      }
      
      try {
        // Helper function to get value by column name
        String? getValue(String columnName) {
          final index = headers.indexOf(columnName.toLowerCase());
          if (index == -1 || index >= row.length) return null;
          final value = row[index];
          if (value == null) return null;
          String strValue = value.toString().trim();
          return (strValue.isEmpty || strValue == "-" || strValue == "null") ? null : strValue;
        }
        
        // Get integer value with validation
        int getInt(String columnName) {
          final value = getValue(columnName);
          if (value == null || value.isEmpty) return 0;
          final parsed = int.tryParse(value);
          return parsed ?? 0;
        }
        
        // Convert Y/N to 1/0
        int getYesNo(String columnName) {
          final value = getValue(columnName)?.toUpperCase() ?? '';
          return (value == 'Y' || value == 'YES') ? 1 : 0;
        }
        
        // Create household object
        final household = Household(
          id: null,
          householdNo: nextHouseholdNo, // Auto-generate new number
          
          // Basic info
          zone: getValue("zone"),
          barangay: barangay,
          
          // Program flags
          fourPs: getYesNo("4ps"),
          indigenousPeople: getYesNo("ip"),
          iodizedSalt: getYesNo("salt"),
          
          // Father info
          fatherName: getValue("father name"),
          fatherOccupation: getValue("father occupation"),
          fatherEducation: getValue("father education"),
          
          // Mother info
          motherName: getValue("mother name"),
          motherOccupation: getValue("mother occupation"),
          motherEducation: getValue("mother education"),
          
          // Demographics
          male: getInt("male"),
          female: getInt("female"),
          total: getInt("total"),
          families: getInt("families"),
          fullyImmunized: getInt("fully immunized"),
          
          // Age groups
          infant0to5: getInt("0-5"),
          infant6to11: getInt("6-11"),
          child12to23: getInt("12-23"),
          child24to59: getInt("24-59"),
          age5to9: getInt("5-9"),
          age10to19: getInt("10-19"),
          age20to59: getInt("20-59"),
          age60above: getInt("60+"),
          pwd: getInt("pwd"),
          
          // Women status
          preg19: getInt("preg <19"),
          preg20: getInt("preg 20+"),
          lactating: getInt("lactating"),
          
          // IYCF
          exclusive: getInt("0-5 exclusive"),
          mixed: getInt("0-5 mixed"),
          bottleFed: getInt("0-5 bottle-fed"),
          complementary: getInt("6-12 complementary"),
          
          // Nutritional status
          severelyUnderweight: getInt("sev uw"),
          underweight: getInt("uw"),
          normal: getInt("normal"),
          severelyWasted: getInt("sev w"),
          wasted: getInt("w"),
          overweight: getInt("ow"),
          obese: getInt("obese"),
          severelyStunted: getInt("sev st"),
          stunted: getInt("st"),
          
          // Facilities
          toilet: getValue("toilet"),
          garbage: getValue("garbage"),
          water: getValue("water"),
          food: getValue("food"),
          dwellingType: getValue("dwelling"),
          
          // Timestamps
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        
        // Optional: Additional validation - skip if completely empty household
        bool hasAnyData = (household.fatherName != null) ||
                          (household.motherName != null) ||
                          (household.zone != null) ||
                          (household.total ?? 0) > 0;
        
        if (!hasAnyData) {
          skippedCount++;
          continue;
        }
        
        // 6. Save to database
        await DBHelper.instance.insertHousehold(household.toMap(), userId);
        importedCount++;
        nextHouseholdNo++;
        
      } catch (e, stackTrace) {
        errorCount++;
        errors.add("Row ${i + 1}: $e");
        print('Error importing row ${i + 1}: $e');
        print(stackTrace);
      }
    }
    
    // 7. Return result with detailed statistics
    String message;
    if (importedCount == 0) {
      message = 'No valid households found. '
                'Empty rows: $skippedCount, '
                'Errors: $errorCount. '
                'Please check that your CSV has valid household data.';
    } else {
      message = 'Successfully imported $importedCount households. '
                'Skipped $skippedCount empty/invalid rows. '
                'Errors: $errorCount.';
    }
    
    return ImportResult(
      success: importedCount > 0,
      message: message,
      importedCount: importedCount,
      errorCount: errorCount,
      errors: errors,
      skippedCount: skippedCount,
    );
  }
}

// Updated Result class with skippedCount
class ImportResult {
  final bool success;
  final String message;
  final int importedCount;
  final int errorCount;
  final int skippedCount;
  final List<String> errors;
  
  ImportResult({
    required this.success,
    required this.message,
    this.importedCount = 0,
    this.errorCount = 0,
    this.skippedCount = 0,
    this.errors = const [],
  });
}