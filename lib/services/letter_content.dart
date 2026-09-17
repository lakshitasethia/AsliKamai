import '../models/letter_template.dart';

/// All the fields any of the three letter templates might need. Fields not
/// relevant to a given template are simply left null and ignored by that
/// template's builder.
class LetterData {
  LetterData({
    required this.riderName,
    required this.platform,
    required this.todayDate,
    this.orderRef,
    this.orderDate,
    this.orderAmount,
    this.blockDate,
    this.details,
  });

  final String riderName;
  final String platform;
  final String todayDate;
  final String? orderRef;
  final String? orderDate;
  final String? orderAmount;
  final String? blockDate;
  final String? details;
}

/// Builds the body text for one letter. Templates cite specific provisions
/// of the Karnataka Platform-Based Gig Workers (Registration and Welfare)
/// Rules, 2025 (research.md §3.4/3.8). Framed throughout as information
/// requests, never as legal claims — see the disclaimer added separately
/// by letter_pdf_export.dart on every generated page.
///
/// TODO(legal-review): every template below is a first-draft translation,
/// not reviewed by a labour lawyer or union — per research.md's explicit
/// instruction, this must happen before any real rider relies on these
/// letters in an actual dispute. Do not remove this TODO until that review
/// has happened.
String buildLetterBody({
  required LetterTemplateType type,
  required LetterLanguage lang,
  required LetterData data,
}) {
  switch (type) {
    case LetterTemplateType.deductionExplanation:
      return _deductionExplanation(lang, data);
    case LetterTemplateType.idBlockReasons:
      return _idBlockReasons(lang, data);
    case LetterTemplateType.grievanceFiling:
      return _grievanceFiling(lang, data);
  }
}

String _deductionExplanation(LetterLanguage lang, LetterData d) {
  switch (lang) {
    case LetterLanguage.english:
      return '''
Date: ${d.todayDate}

To,
${d.platform} Partner Support

Subject: Request for explanation of deduction — Order ${d.orderRef}

Dear Sir/Madam,

I am a delivery partner with ${d.platform}. On ${d.orderDate}, I completed order ${d.orderRef}, for which I was paid Rs. ${d.orderAmount}. I am writing to request a clear, itemised explanation of how this amount was calculated, including any deductions applied.

Under the Karnataka Platform-Based Gig Workers (Registration and Welfare) Rules, 2025, deductions from a gig worker's earnings must be clearly explained to the worker. I would be grateful if you could share this information at the earliest.

This letter is an information request, not a legal notice.

Regards,
${d.riderName}
''';
    case LetterLanguage.hindi:
      return '''
दिनांक: ${d.todayDate}

सेवा में,
${d.platform} पार्टनर सपोर्ट

विषय: कटौती का स्पष्टीकरण अनुरोध — ऑर्डर ${d.orderRef}

महोदय/महोदया,

मैं ${d.platform} का एक डिलीवरी पार्टनर हूं। ${d.orderDate} को मैंने ऑर्डर ${d.orderRef} पूरा किया, जिसके लिए मुझे ₹${d.orderAmount} का भुगतान किया गया। मैं अनुरोध करता हूं कि यह राशि कैसे तय की गई, इसकी स्पष्ट और विस्तृत जानकारी दी जाए, जिसमें की गई किसी भी कटौती का विवरण शामिल हो।

कर्नाटक प्लेटफ़ॉर्म-आधारित गिग वर्कर्स (पंजीकरण और कल्याण) नियम, 2025 के अनुसार, गिग वर्कर की कमाई से की जाने वाली किसी भी कटौती को स्पष्ट रूप से समझाया जाना आवश्यक है। कृपया यह जानकारी जल्द से जल्द साझा करें।

यह पत्र एक सूचना अनुरोध है, कानूनी नोटिस नहीं।

सधन्यवाद,
${d.riderName}
''';
    case LetterLanguage.kannada:
      return '''
ದಿನಾಂಕ: ${d.todayDate}

ಸೇವೆಯಲ್ಲಿ,
${d.platform} ಪಾರ್ಟ್‌ನರ್ ಸಪೋರ್ಟ್

ವಿಷಯ: ಕಡಿತದ ವಿವರಣೆ ಕೋರಿಕೆ — ಆರ್ಡರ್ ${d.orderRef}

ಮಾನ್ಯರೆ,

ನಾನು ${d.platform} ನ ಡೆಲಿವರಿ ಪಾರ್ಟ್‌ನರ್ ಆಗಿದ್ದೇನೆ. ${d.orderDate} ರಂದು ನಾನು ಆರ್ಡರ್ ${d.orderRef} ಅನ್ನು ಪೂರ್ಣಗೊಳಿಸಿದೆ, ಇದಕ್ಕಾಗಿ ನನಗೆ ₹${d.orderAmount} ಪಾವತಿಸಲಾಗಿದೆ. ಈ ಮೊತ್ತವನ್ನು ಹೇಗೆ ಲೆಕ್ಕಹಾಕಲಾಗಿದೆ ಎಂಬುದರ ಸ್ಪಷ್ಟ ಮತ್ತು ವಿವರವಾದ ಮಾಹಿತಿಯನ್ನು, ಯಾವುದೇ ಕಡಿತಗಳ ವಿವರಗಳೊಂದಿಗೆ, ನೀಡಬೇಕೆಂದು ವಿನಂತಿಸುತ್ತೇನೆ.

ಕರ್ನಾಟಕ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಆಧಾರಿತ ಗಿಗ್ ಕಾರ್ಮಿಕರ (ನೋಂದಣಿ ಮತ್ತು ಕಲ್ಯಾಣ) ನಿಯಮಗಳು, 2025 ರ ಪ್ರಕಾರ, ಗಿಗ್ ಕಾರ್ಮಿಕರ ಗಳಿಕೆಯಿಂದ ಮಾಡುವ ಯಾವುದೇ ಕಡಿತವನ್ನು ಸ್ಪಷ್ಟವಾಗಿ ವಿವರಿಸಬೇಕು. ದಯವಿಟ್ಟು ಈ ಮಾಹಿತಿಯನ್ನು ಆದಷ್ಟು ಬೇಗ ಹಂಚಿಕೊಳ್ಳಿ.

ಇದು ಒಂದು ಮಾಹಿತಿ ಕೋರಿಕೆ, ಕಾನೂನು ನೋಟಿಸ್ ಅಲ್ಲ.

ಧನ್ಯವಾದಗಳು,
${d.riderName}
''';
  }
}

String _idBlockReasons(LetterLanguage lang, LetterData d) {
  switch (lang) {
    case LetterLanguage.english:
      return '''
Date: ${d.todayDate}

To,
${d.platform} Partner Support

Subject: Request for written reasons — account block dated ${d.blockDate}

Dear Sir/Madam,

My partner account with ${d.platform} was blocked on ${d.blockDate}. Under the Karnataka Platform-Based Gig Workers (Registration and Welfare) Rules, 2025, a platform must give a gig worker 14 days' notice along with written reasons before blocking their ID.

I have not received written reasons for this block. I am requesting that these be shared with me in writing at the earliest, along with any steps available to appeal this decision.

This letter is an information request, not a legal notice.

Regards,
${d.riderName}
''';
    case LetterLanguage.hindi:
      return '''
दिनांक: ${d.todayDate}

सेवा में,
${d.platform} पार्टनर सपोर्ट

विषय: लिखित कारण का अनुरोध — खाता ब्लॉक दिनांक ${d.blockDate}

महोदय/महोदया,

मेरा ${d.platform} पार्टनर खाता ${d.blockDate} को ब्लॉक कर दिया गया। कर्नाटक प्लेटफ़ॉर्म-आधारित गिग वर्कर्स (पंजीकरण और कल्याण) नियम, 2025 के अनुसार, किसी गिग वर्कर की आईडी ब्लॉक करने से पहले प्लेटफ़ॉर्म को 14 दिनों की सूचना के साथ लिखित कारण देना आवश्यक है।

मुझे इस ब्लॉक के लिए अभी तक कोई लिखित कारण नहीं मिला है। कृपया यह कारण जल्द से जल्द लिखित रूप में मुझे उपलब्ध कराएं, साथ ही इस निर्णय के खिलाफ अपील करने के उपलब्ध विकल्पों की जानकारी भी दें।

यह पत्र एक सूचना अनुरोध है, कानूनी नोटिस नहीं।

सधन्यवाद,
${d.riderName}
''';
    case LetterLanguage.kannada:
      return '''
ದಿನಾಂಕ: ${d.todayDate}

ಸೇವೆಯಲ್ಲಿ,
${d.platform} ಪಾರ್ಟ್‌ನರ್ ಸಪೋರ್ಟ್

ವಿಷಯ: ಲಿಖಿತ ಕಾರಣದ ಕೋರಿಕೆ — ಖಾತೆ ಬ್ಲಾಕ್ ದಿನಾಂಕ ${d.blockDate}

ಮಾನ್ಯರೆ,

ನನ್ನ ${d.platform} ಪಾರ್ಟ್‌ನರ್ ಖಾತೆಯನ್ನು ${d.blockDate} ರಂದು ಬ್ಲಾಕ್ ಮಾಡಲಾಗಿದೆ. ಕರ್ನಾಟಕ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಆಧಾರಿತ ಗಿಗ್ ಕಾರ್ಮಿಕರ (ನೋಂದಣಿ ಮತ್ತು ಕಲ್ಯಾಣ) ನಿಯಮಗಳು, 2025 ರ ಪ್ರಕಾರ, ಗಿಗ್ ಕಾರ್ಮಿಕರ ಐಡಿಯನ್ನು ಬ್ಲಾಕ್ ಮಾಡುವ ಮೊದಲು ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ 14 ದಿನಗಳ ಸೂಚನೆಯೊಂದಿಗೆ ಲಿಖಿತ ಕಾರಣಗಳನ್ನು ನೀಡಬೇಕು.

ಈ ಬ್ಲಾಕ್‌ಗೆ ಇನ್ನೂ ಯಾವುದೇ ಲಿಖಿತ ಕಾರಣ ನನಗೆ ಸಿಕ್ಕಿಲ್ಲ. ದಯವಿಟ್ಟು ಈ ಕಾರಣಗಳನ್ನು ಆದಷ್ಟು ಬೇಗ ಲಿಖಿತ ರೂಪದಲ್ಲಿ ನನಗೆ ಒದಗಿಸಿ, ಜೊತೆಗೆ ಈ ನಿರ್ಧಾರದ ವಿರುದ್ಧ ಮೇಲ್ಮನವಿ ಸಲ್ಲಿಸಲು ಲಭ್ಯವಿರುವ ಆಯ್ಕೆಗಳ ಮಾಹಿತಿಯನ್ನೂ ನೀಡಿ.

ಇದು ಒಂದು ಮಾಹಿತಿ ಕೋರಿಕೆ, ಕಾನೂನು ನೋಟಿಸ್ ಅಲ್ಲ.

ಧನ್ಯವಾದಗಳು,
${d.riderName}
''';
  }
}

String _grievanceFiling(LetterLanguage lang, LetterData d) {
  switch (lang) {
    case LetterLanguage.english:
      return '''
Date: ${d.todayDate}

To,
${d.platform} Internal Dispute Resolution Committee

Subject: Grievance regarding my account with ${d.platform}

Dear Sir/Madam,

I am a delivery partner with ${d.platform}. I am filing this grievance regarding the following issue:

${d.details}

Under the Karnataka Platform-Based Gig Workers (Registration and Welfare) Rules, 2025, platforms are required to maintain an internal dispute committee to address such grievances, with a right of appeal to the Karnataka Gig Workers Welfare Board if the matter is not resolved.

I request that this grievance be examined and resolved at the earliest. If it is not resolved to my satisfaction, I intend to escalate this matter to the Board.

This letter is an information request, not a legal notice.

Regards,
${d.riderName}
''';
    case LetterLanguage.hindi:
      return '''
दिनांक: ${d.todayDate}

सेवा में,
${d.platform} आंतरिक विवाद समाधान समिति

विषय: ${d.platform} के साथ मेरे खाते से संबंधित शिकायत

महोदय/महोदया,

मैं ${d.platform} का एक डिलीवरी पार्टनर हूं। मैं निम्नलिखित समस्या के संबंध में यह शिकायत दर्ज कर रहा हूं:

${d.details}

कर्नाटक प्लेटफ़ॉर्म-आधारित गिग वर्कर्स (पंजीकरण और कल्याण) नियम, 2025 के अनुसार, प्लेटफ़ॉर्म को ऐसी शिकायतों के समाधान के लिए एक आंतरिक विवाद समिति रखना आवश्यक है, और यदि मामला हल न हो, तो कर्नाटक गिग वर्कर्स कल्याण बोर्ड में अपील का अधिकार है।

मैं अनुरोध करता हूं कि इस शिकायत की जांच कर इसे जल्द से जल्द हल किया जाए। यदि यह मेरी संतुष्टि के अनुसार हल नहीं होता है, तो मैं इस मामले को बोर्ड तक ले जाने का इरादा रखता हूं।

यह पत्र एक सूचना अनुरोध है, कानूनी नोटिस नहीं।

सधन्यवाद,
${d.riderName}
''';
    case LetterLanguage.kannada:
      return '''
ದಿನಾಂಕ: ${d.todayDate}

ಸೇವೆಯಲ್ಲಿ,
${d.platform} ಆಂತರಿಕ ವಿವಾದ ಪರಿಹಾರ ಸಮಿತಿ

ವಿಷಯ: ${d.platform} ನೊಂದಿಗಿನ ನನ್ನ ಖಾತೆಗೆ ಸಂಬಂಧಿಸಿದ ದೂರು

ಮಾನ್ಯರೆ,

ನಾನು ${d.platform} ನ ಡೆಲಿವರಿ ಪಾರ್ಟ್‌ನರ್ ಆಗಿದ್ದೇನೆ. ಈ ಕೆಳಗಿನ ಸಮಸ್ಯೆಗೆ ಸಂಬಂಧಿಸಿದಂತೆ ನಾನು ಈ ದೂರನ್ನು ದಾಖಲಿಸುತ್ತಿದ್ದೇನೆ:

${d.details}

ಕರ್ನಾಟಕ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಆಧಾರಿತ ಗಿಗ್ ಕಾರ್ಮಿಕರ (ನೋಂದಣಿ ಮತ್ತು ಕಲ್ಯಾಣ) ನಿಯಮಗಳು, 2025 ರ ಪ್ರಕಾರ, ಇಂತಹ ದೂರುಗಳನ್ನು ಪರಿಹರಿಸಲು ಪ್ಲಾಟ್‌ಫಾರ್ಮ್‌ಗಳು ಆಂತರಿಕ ವಿವಾದ ಸಮಿತಿಯನ್ನು ಹೊಂದಿರಬೇಕು, ಮತ್ತು ಸಮಸ್ಯೆ ಪರಿಹಾರವಾಗದಿದ್ದರೆ ಕರ್ನಾಟಕ ಗಿಗ್ ಕಾರ್ಮಿಕರ ಕಲ್ಯಾಣ ಮಂಡಳಿಗೆ ಮೇಲ್ಮನವಿ ಸಲ್ಲಿಸುವ ಹಕ್ಕಿದೆ.

ಈ ದೂರನ್ನು ಪರಿಶೀಲಿಸಿ ಆದಷ್ಟು ಬೇಗ ಪರಿಹರಿಸಬೇಕೆಂದು ವಿನಂತಿಸುತ್ತೇನೆ. ನನ್ನ ತೃಪ್ತಿಗೆ ಪರಿಹಾರವಾಗದಿದ್ದರೆ, ಈ ವಿಷಯವನ್ನು ಮಂಡಳಿಗೆ ಕೊಂಡೊಯ್ಯಲು ನಾನು ಉದ್ದೇಶಿಸಿದ್ದೇನೆ.

ಇದು ಒಂದು ಮಾಹಿತಿ ಕೋರಿಕೆ, ಕಾನೂನು ನೋಟಿಸ್ ಅಲ್ಲ.

ಧನ್ಯವಾದಗಳು,
${d.riderName}
''';
  }
}
