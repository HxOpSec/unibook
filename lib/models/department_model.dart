import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DepartmentModel {
  const DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    required this.facultyId,
    required this.facultyName,
    required this.building,
    required this.room,
    required this.icon,
    required this.color,
    required this.bookCount,
    required this.createdAt,
    this.head = '',
  });

  final String id;
  final String name;
  final String code;
  final String facultyId;
  final String facultyName;
  final String building;
  final String room;
  final String icon;
  final String color;
  final String head;
  final int bookCount;
  final DateTime createdAt;

  Color get colorValue {
    final hex = color.replaceFirst('#', '');
    final normalized = hex.length == 6 ? 'FF$hex' : hex;
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) return const Color(0xFF1565C0);
    return Color(parsed);
  }

  IconData get iconData {
    switch (icon) {
      case 'public':
        return Icons.public;
      case 'security':
        return Icons.security;
      case 'trending_up':
        return Icons.trending_up;
      case 'account_balance':
        return Icons.account_balance;
      case 'payments':
        return Icons.payments;
      case 'bar_chart':
        return Icons.bar_chart;
      case 'fact_check':
        return Icons.fact_check;
      case 'calculate':
        return Icons.calculate;
      case 'manage_accounts':
        return Icons.manage_accounts;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'computer':
        return Icons.computer;
      case 'devices':
        return Icons.devices;
      case 'hub':
        return Icons.hub;
      case 'currency_exchange':
        return Icons.currency_exchange;
      case 'business_center':
        return Icons.business_center;
      case 'gavel':
        return Icons.gavel;
      case 'store':
        return Icons.store;
      case 'school':
        return Icons.school;
      case 'language':
        return Icons.language;
      case 'translate':
        return Icons.translate;
      case 'functions':
        return Icons.functions;
      case 'sports':
        return Icons.sports;
      case 'history_edu':
        return Icons.history_edu;
      case 'analytics':
        return Icons.analytics;
      default:
        return Icons.apartment;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'building': building,
      'room': room,
      'icon': icon,
      'color': color,
      'head': head,
      'bookCount': bookCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory DepartmentModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    return DepartmentModel(
      id: id,
      name: (map['name'] ?? '') as String,
      code: (map['code'] ?? '') as String,
      facultyId: (map['facultyId'] ?? '') as String,
      facultyName: (map['facultyName'] ?? '') as String,
      building: (map['building'] ?? '') as String,
      room: (map['room'] ?? '') as String,
      icon: (map['icon'] ?? 'school') as String,
      color: (map['color'] ?? '#1565C0') as String,
      head: (map['head'] ?? '') as String,
      bookCount: ((map['bookCount'] ?? 0) as num).toInt(),
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse(createdAtRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
