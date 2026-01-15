part of 'shared.dart';

// 🎨 Warna utama
const Color primaryColor = Color(0xFF88BDF2);
const Color secondaryColor = Color(0xFF6A89A7);
const Color dangerColor = Color(0xFF384959);
const Color blackColor = Color(0xFF000000);
const Color whiteColor = Colors.white;
const Color backgroundColor = Color(0xFFF6F8FB);

// Margin default
const double defaultMargin = 24;

// TextStyle dasar
TextStyle blackTextStyle = GoogleFonts.poppins(
  color: blackColor,
);
TextStyle greyTextStyle = GoogleFonts.poppins(
  color: Colors.grey,
);
TextStyle whiteTextStyle = GoogleFonts.poppins(
  color: whiteColor,
);
TextStyle primaryTextStyle = GoogleFonts.poppins(
  color: primaryColor,
);


TextStyle regularTextStyle = GoogleFonts.poppins(
  color: blackColor,
  fontWeight: FontWeight.w400,
);

TextStyle mediumTextStyle = GoogleFonts.poppins(
  color: blackColor,
  fontWeight: FontWeight.w500,
);

TextStyle semiBoldTextStyle = GoogleFonts.poppins(
  color: blackColor,
  fontWeight: FontWeight.w600,
);

TextStyle boldTextStyle = GoogleFonts.poppins(
  color: blackColor,
  fontWeight: FontWeight.w700,
);
