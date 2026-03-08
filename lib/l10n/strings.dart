class AppStrings {
  final bool isAmharic;
  const AppStrings._(this.isAmharic);
  static const AppStrings am = AppStrings._(true);
  static const AppStrings en = AppStrings._(false);

  // Currency helper
  String formatCurrency(double amount) {
    return "${isAmharic ? 'ብር' : 'ETB'} ${amount.toStringAsFixed(2)}";
  }

  // App
  String get appNamePart1    => isAmharic ? "ስሞኦን "                 : "Simon";
  String get appNamePart2    => isAmharic ? " ግሮሰሪ"                  : " Grocery";

  // Language toggle
  String get langAmharic     => "አማርኛ";
  String get langEnglish     => "English";
  String get selectLanguage  => isAmharic ? "ቋንቋ ምረጥ"             : "Select Language";

  // Common
  String get save            => isAmharic ? "አስቀምጥ"               : "Save";
  String get cancel          => isAmharic ? "ሰርዝ"                 : "Cancel";
  String get add             => isAmharic ? "አክል"                 : "Add";
  String get edit            => isAmharic ? "አርም"                 : "Edit";
  String get saveAndContinue => isAmharic ? "አስቀምጥና ቀጥል"         : "Save & Continue";
  String get required        => isAmharic ? "ያስፈልጋል"              : "Required";
  String get invalid         => isAmharic ? "ትክክል አይደለም"          : "Invalid";
  String get doLater         => isAmharic ? "በኋላ አደርጋለሁ"          : "Do it later";
  String get saveChanges     => isAmharic ? "ለውጦችን አስቀምጥ"         : "Save Changes";
  String get deactivate      => isAmharic ? "አቁም"                 : "Deactivate";
  String get logout          => isAmharic ? "ውጣ"                   : "Logout";

  // Home
  String get manageProducts  => isAmharic ? "እቃዎችን አስተዳድር"        : "Manage Products";
  String get totalRevenue    => isAmharic ? "ጠቅላላ ገቢ"             : "Total Revenue";
  String get netProfit       => isAmharic ? "ተጣራ ትርፍ"             : "Net Profit";
  String get bestDay         => isAmharic ? "ትርፋማ ቀን"              : "Best Day";
  String get expensesLabel   => isAmharic ? "ወጪዎች"               : "Expenses";
  String get daysLogged      => isAmharic ? "ቀናት ተመዝግቧል"          : "days logged";

  // Welcome modal
  String get welcomeTitle    => isAmharic ? "እንኳን ደህና መጡ"         : "Welcome";
  String get welcomeBody     => isAmharic
      ? "ለመጀመሪያ ጊዜ እዚህ ነዎት! ከመጀመርዎ በፊት የእቃዎችን ዝርዝርዎን ያዘጋጁ።"
      : "First time here! Set up your product list before you start logging.";
  String get setupProducts   => isAmharic ? "ምርቶችን አዘጋጅ"          : "Set Up Products";

  // Products
  String get products        => isAmharic ? "እቃዎች"               : "Products";
  String get productList     => isAmharic ? "የእቃዎችን ዝርዝር"           : "Product List";
  String get productListSub  => isAmharic
      ? "የእቃዎችን ዝርዝር፣ የግዥ ዋጋ እና የሽያጭ ዋጋ ያቀናብሩ።"
      : "Manage your items, buy prices and sell prices.";
  String get noProducts      => isAmharic ? "እቃ አልተጨመረም"         : "No products yet";
  String get noProductsSub   => isAmharic
      ? "የመጀመሪያ እቃዎችን ለመጨመር ከላይ ያለውን አክል ቁልፍ ይጫኑ።"
      : "Tap the Add button above to create your first product.";
  String get addFirstProduct => isAmharic ? "መጀመሪያ እቃ አክል"       : "Add First Product";
  String get addProduct      => isAmharic ? "ምርት አክል"             : "Add Product";
  String get editProduct     => isAmharic ? "ምርት አርም"             : "Edit Product";
  String get productName     => isAmharic ? "የምርት ስም"             : "Product Name";
  String get buyPrice        => isAmharic ? "የግዥ ዋጋ"              : "Buy Price";
  String get sellPrice       => isAmharic ? "የሽያጭ ዋጋ"             : "Sell Price";
  String get openingStockUnits => isAmharic ? "መጀመሪያ ግሮሰሪ ውስጥ የነበረ እቃ" : "Opening Stock (units)";
  String get units           => isAmharic ? "ፍሬ"               : "units";
  String get buy             => isAmharic ? "መግዣ ዋጋ"                 : "Buy";
  String get sell            => isAmharic ? "መሸጫ ዋጋ"                 : "Sell";
  String get productDetails  => isAmharic ? "የእቃዎችን ዝርዝር እና ዋጋዎች ያስገቡ።" : "Enter the product details and prices.";
  String get deactivateTitle => isAmharic ? "እቃን ያቁሙ?"           : "Deactivate product?";
  String get deactivateBody  => isAmharic
      ? "እቃዎ ከዕለታዊ ዝርዝር ይወጣል። ታሪኩ ይቀመጣል።"
      : "This product will be hidden from daily entry. History is preserved.";
  String openingStockLabel(int n) =>
      isAmharic ? "መጀመሪያ እቃዎችን : $n ፍሬ" : "Opening stock: $n units";

  // Step badge
  String step(int current, int total) =>
      isAmharic ? "ደረጃ $current/$total" : "Step $current of $total";

  // Step 2 - Purchases
  String get dailyPurchases    => isAmharic ? "ዕለታዊ ግዥዎች"         : "Daily Purchases";
  String get dailyPurchasesSub => isAmharic ? "ዛሬ ምን ዕቃ ዳግም ሞሉ?" : "What did you restock today?";
  String get qtyPurchased      => isAmharic ? "የተገዛ መጠን"           : "Qty Purchased";

  // Step 3 - Price check
  String get sellingPrices   => isAmharic ? "የመሸጫ ዋጋዎች"           : "Selling Prices";
  String get priceCheck      => isAmharic ? "ዋጋ ማረጋገጫ"            : "Price Check";
  String get priceCheckSub   => isAmharic
      ? "የዛሬውን የሽያጭ ዋጋ ያረጋግጡ ወይም ያስተካክሉ።"
      : "Confirm or update today selling prices.";
  String get confirmPrices   => isAmharic ? "ዋጋዎችን አረጋግጥ"          : "Confirm Prices";

  // Step 4 - Sales
  String get dailySales      => isAmharic ? "ዕለታዊ ሽያጭ"            : "Daily Sales";
  String get logSales        => isAmharic ? "ሽያጭ መዝግብ"            : "Log Sales";
  String get logSalesSub     => isAmharic ? "ዛሬ ስንት ፍሬ ሸጡ?"     : "How many units did you sell today?";
  String get todayRevenue    => isAmharic ? "የዛሬ ጠቅላላ ገቢ"          : "Today Revenue";
  String get revenue         => isAmharic ? "ገቢ"                  : "Revenue";
  String get nextExpenses    => isAmharic ? "ቀጥል: የቤት ወጪዎች"       : "Next: Household Expenses";
  String availableLabel(int n, String price) =>
      isAmharic ? "ያለ: $n ፍሬ  .  @ $price" : "Available: $n  .  @ $price";
  String revenueLabel(String amount) =>
      isAmharic ? "ገቢ: $amount" : "Revenue: $amount";

  // Step 5 - Household expenses
  String get householdExpenses    => isAmharic ? "የቤት ወጪዎች"        : "Household Expenses";
  String get householdExpensesSub => isAmharic
      ? "ዛሬ ከገቢ የወጡ የቤት ወጪዎችን ይዘግቡ።"
      : "Log any home expenses paid from today takings.";
  String get expenseInfo     => isAmharic
      ? "እነዚህ ወጪዎች በተናጠል ይመዘገባሉ እና ከጠቅላላ ትርፍ ይቀነሳሉ።"
      : "Tracked separately and deducted from gross profit.";
  String get noExpenses      => isAmharic
      ? "ምንም ወጪ አልተመዘገበም።"
      : "No expenses logged yet.";
  String get addExpense      => isAmharic ? "ወጪ አክል"              : "Add Expense";
  String get editExpense     => isAmharic ? "ወጪ አርም"              : "Edit Expense";
  String get expenseDetails  => isAmharic
      ? "ከዕለታዊ ትርፍ የሚቀነስ የቤት ወጪ ያስገቡ።"
      : "Log a household expense deducted from profit.";
  String get descriptionLabel => isAmharic ? "መግለጫ"              : "Description";
  String get amountLabel     => isAmharic ? "መጠን"                : "Amount";
  String get quickPick       => isAmharic ? "ፈጣን ምርጫ"            : "Quick Pick";
  String get validAmount     => isAmharic ? "ትክክለኛ መጠን ያስገቡ"     : "Enter a valid amount";
  String get continueToSummary => isAmharic ? "ወደ ማጠቃለያ ቀጥል"    : "Continue to Summary";
  String get grossProfit     => isAmharic ? "ጠቅላላ ትርፍ"           : "Gross Profit";
  String get totalExpenses   => isAmharic ? "ጠቅላላ ወጪ"            : "Total Expenses";
  List<(String, String)> get expenseCategories => isAmharic
      ? [("🛒","ሸቀጣሸቀጥ"),("💡","ኤሌክትሪክ"),("💧","ውሃ"),("🚌","መጓጓዣ"),("🏥","ህክምና"),("📱","ስልክ ክሬዲት"),("🏠","ቤት ኪራይ"),("⛽","ነዳጅ"),("🧹","ጽዳት"),("🍽️","ምግብ")]
      : [("🛒","Groceries"),("💡","Electricity"),("💧","Water"),("🚌","Transport"),("🏥","Medical"),("📱","Airtime"),("🏠","Rent"),("⛽","Petrol"),("🧹","Cleaning"),("🍽️","Food")];

  // Step 6 - Summary
  String get dailySummary    => isAmharic ? "ዕለታዊ ማጠቃለያ"          : "Daily Summary";
  String get endOfDay        => isAmharic ? "የቀኑ መጨረሻ"            : "End of Day";
  String get endOfDaySub     => isAmharic ? "ዕለታዊ ማጠቃለያዎን ይገምግሙ።" : "Review your daily summary below.";
  String get colProduct      => isAmharic ? "ምርት"                 : "Product";
  String get colOpen         => isAmharic ? "መጀምሪያ"               : "Open";
  String get colBought       => isAmharic ? "+ግዥ"                 : "+Bought";
  String get colSold         => isAmharic ? "ሽያጭ"                 : "Sold";
  String get colClose        => isAmharic ? "ቀሪ"                  : "Close";
  String get colRevenue      => isAmharic ? "ገቢ"                  : "Revenue";
  String get lowStockWarning => isAmharic ? "እቃው እያለቀ መሆኑ ማስጠንቀቂያ"  : "Low Stock Warnings";
  String lowStockMsg(String name, int n) =>
      isAmharic ? "$name: ቀሪ $n ክፍሎች ብቻ" : "$name: only $n units left";
  String get markComplete    => isAmharic ? "ቀን ተጠናቋል"             : "Mark Day as Complete";
  String get minusExpenses   => isAmharic ? "- ወጪዎች"              : "Expenses";

  // Login & Signup
  String get login           => isAmharic ? "ግባ"                   : "Login";
  String get signUp          => isAmharic ? "ተመዝገብ"                : "Sign Up";
  String get email           => isAmharic ? "መለያ"                 : "Username";
  String get password        => isAmharic ? "የይለፍ ቃል"              : "Password";
  String get confirmPassword => isAmharic ? "የይለፍ ቃል አረጋግጥ"       : "Confirm Password";
  String get dontHaveAccount => isAmharic ? "መለያ የለዎትም? ተመዝገብ"    : "Don't have an account? Sign Up";
  String get alreadyHaveAccount => isAmharic ? "ቀድሞውኑ መለያ አለዎት? ግባ"  : "Already have an account? Login";
  String get pleaseVerifyEmail => isAmharic 
      ? "እባክዎን ኢሜይልዎን ያረጋግጡ። የማረጋገጫ ሊንክ ተልኳል።" 
      : "Please verify your email. A verification link has been sent.";
}
