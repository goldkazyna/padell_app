import 'package:flutter/material.dart';

class BannerAccent {
  final Color tone;
  final Color stroke;
  final Color glow;
  final Color badgeBg;
  final Color badgeBorder;
  final Color ico;

  const BannerAccent({
    required this.tone,
    required this.stroke,
    required this.glow,
    required this.badgeBg,
    required this.badgeBorder,
    required this.ico,
  });
}

const BannerAccent kBannerGreen = BannerAccent(
  tone: Color(0xFF1C1D24),
  stroke: Color(0x5222C47A),
  glow: Color(0x2922C47A),
  badgeBg: Color(0x1F22C47A),
  badgeBorder: Color(0x4722C47A),
  ico: Color(0xFF22C47A),
);

const BannerAccent kBannerBlue = BannerAccent(
  tone: Color(0xFF1D1E23),
  stroke: Color(0x524A8BF5),
  glow: Color(0x2E4A8BF5),
  badgeBg: Color(0x1F4A8BF5),
  badgeBorder: Color(0x474A8BF5),
  ico: Color(0xFF6AA1FF),
);

const BannerAccent kBannerPurple = BannerAccent(
  tone: Color(0xFF211F24),
  stroke: Color(0x52A89CF5),
  glow: Color(0x2EA89CF5),
  badgeBg: Color(0x21A89CF5),
  badgeBorder: Color(0x4DA89CF5),
  ico: Color(0xFFBCB1FF),
);

const BannerAccent kBannerOrange = BannerAccent(
  tone: Color(0xFF1F1D22),
  stroke: Color(0x52F08446),
  glow: Color(0x2EF08446),
  badgeBg: Color(0x21F08446),
  badgeBorder: Color(0x4DF08446),
  ico: Color(0xFFFF9B62),
);

const BoxShadow kBannerShadow = BoxShadow(
  color: Color(0x73000000),
  blurRadius: 30,
  offset: Offset(0, 14),
);

const Color kBannerTitleColor = Color(0xFFF3F3F5);
const Color kBannerSubColor = Color(0xFF8A8A93);
