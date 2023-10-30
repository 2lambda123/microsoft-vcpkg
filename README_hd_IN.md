# Vcpkg: अवलोकन

[中文总览](README_zh_CN.md)
[Español](README_es.md)
[한국어](README_ko_KR.md)
[Français](README_fr.md)
[Tiếng Việt](README_vn.md)
[हिन्दी](README_hd_IN.md)

Vcpkg आपको Windows, Linux और MacOS पर C and C++ लाइब्रेरीज़ का प्रबंधन करने में मदद करता है। यह उपकरण और पारिस्थितिकी सदैव विकसित हो रहे हैं, और हम सदैव योगदान की कद्र करते हैं!

यदि आपने पहले कभी Vcpkg का उपयोग नहीं किया है, या यदि आप vcpkg का उपयोग कैसे करें समझने की कोशिश कर रहे हैं,
उपयोग कैसे शुरू करें के लिए हमारे [शुरू हो जाओd](#प्रारंभ करना) खंड की जांच करें।

उपलब्ध आदेशों के लिए संक्षेप में विवरण के लिए, जब आपने vcpkg स्थापित कर लिया हो, आप दौड़ा सकते हैं `vcpkg help`, या विशेष आदेश के लिए `vcpkg help [command]`।

* GitHub: ports at [https://github.com/microsoft/vcpkg](https://github.com/microsoft/vcpkg), पोर्ट्स [https://github.com/microsoft/vcpkg-tool](https://github.com/microsoft/vcpkg-tool) प्रोग्राम
* Slack: [https://cppalliance.org/slack/](https://cppalliance.org/slack/), #vcpkg चैनल
* Discord: [\#include \<C++\>](https://www.includecpp.org), #🌏vcpkg चैनल
* दस्तावेज़ीकरण: [Documentation](https://learn.microsoft.com/vcpkg)

# विषय सूची

- [Vcpkg: अवलोकन](#vcpkg-अवलोकन)
- [विषय सूची](#विषय-सूची)
- [प्रारंभ करना](#प्रारंभ-करना)
  - [त्वरित प्रारंभ: Windows](#त्वरित-प्रारंभ-windows)
  - [त्वरित प्रारंभ: Unix](#त्वरित-प्रारंभ-unix)
  - [Linux Developer Tools स्थापित करना](#linux-developer-tools-स्थापित-करना)
  - [MacOS Developer Tools स्थापित करना](#macos-developer-tools-स्थापित-करना)
  - [CMake के साथ vcpkg का उपयोग करना](#cmake-के-साथ-vcpkg-का-उपयोग-करना)
    - [CMake Tools के साथ विज़ुअल स्टूडियो कोड](#cmake-tools-के-साथ-विज़ुअल-स्टूडियो-कोड)
    - [Visual Studio के साथ Vcpkg CMake परियोजनाएँ](#visual-studio-के-साथ-vcpkg-cmake-परियोजनाएँ)
    - [CLion के साथ Vcpkg](#clion-के-साथ-vcpkg)
    - [CMake के साथ Vcpkg के रूप में एक सबमॉड्यूल के रूप में](#cmake-के-साथ-vcpkg-के-रूप-में-एक-सबमॉड्यूल-के-रूप-में)
- [टैब-सम्पूर्णता/स्वचलन-सम्पूर्णता](#टैब-सम्पूर्णतास्वचलन-सम्पूर्णता)
- [उदाहरण](#उदाहरण)
- [योगदान](#योगदान)
- [लाइसेंस](#लाइसेंस)
- [सुरक्षा](#सुरक्षा)
- [वाद-संग्रह](#वाद-संग्रह)

# प्रारंभ करना

पहले, आपको जो भी उपयोग कर रहे हैं, [Windows](#त्वरित-प्रारंभ-windows), or [macOS और Linux](#त्वरित-प्रारंभ-unix),
 के लिए, उसके लिए त्वरित प्रारंभ गाइड का पालन करें।

अधिक जानकारी के लिए, [Packages स्थापित करने और उपयोग करने के लिए][getting-started:using-a-package] देखें।
यदि वह पुस्तकालय जिसकी आपको आवश्यकता है vcpkg डेटाबेस में मौजूद नहीं है,
तो आप [open an issue on the GitHub repo][contributing:submit-issue]
जहां वीसीपीके टीम और समुदाय इसे देख सकते हैं,
और संभावित रूप से पोर्ट को vcpkg में जोड़ सकते हैं।

vcpkg को स्थापित और काम करते हुए प्राप्त करने के बाद,
आप अपने शैल में [tab पूर्णता](#टैब-सम्पूर्णतास्वचलन-सम्पूर्णता) जोड़ना चाह सकते हैं।

## त्वरित प्रारंभ: Windows

प्राथमिक आवश्यकताएं:
- Windows 7 या नवीनतम संस्करण
- [Git][getting-started:git]
- [Visual Studio][getting-started:visual-studio] 2015 अपडेट 3 या उससे अधिक संस्करण, जिसमें अंग्रेजी भाषा पैक संस्करण प्रयुक्त हो

पहले, vcpkg खुद को डाउनलोड और bootstrap करें; इसे कहीं भी स्थापित किया जा सकता है, लेकिन आमतौर पर हम सिफारिश करते हैं कि vcpkg को उपयोग करने वाले रेपो को स्वतंत्र रूप से रहने दिया जाए। वैसे भी, vcpkg वैश्विक रूप से स्थापित किया जा सकता है; हम सिफारिश करते हैं कि आप `C:\src\vcpkg` या `C:\dev\vcpkg` जैसी कोई अन्य स्थान स्थापित करें, क्योंकि अन्यथा कुछ पोर्ट निर्माण सिस्टम के लिए मार्ग समस्याएं उत्पन्न हो सकती हैं।

```cmd
> git clone https://github.com/microsoft/vcpkg
> .\vcpkg\bootstrap-vcpkg.bat
```

अपने परियोजना के लिए पुस्तकालयों को स्थापित करने के लिए, निम्नलिखित कमांड चलाएँ:

```cmd
> .\vcpkg\vcpkg install [स्थापित करने के लिए पैकेज]
```

नोट: यह डिफ़ॉल्ट रूप से x86 पुस्तकालयों को स्थापित करेगा। x64 स्थापित करने के लिए, निम्नलिखित कमांड चलाएँ:

```cmd
> .\vcpkg\vcpkg install [package name]:x64-windows
```

या

```cmd
> .\vcpkg\vcpkg install [स्थापित करने के लिए पैकेज] --triplet=x64-windows
```

आप चाहें तो `search` उप-कमांड के साथ आपकी आवश्यकताओं के लिए पुस्तकालयों की खोज भी कर सकते हैं:

```cmd
> .\vcpkg\vcpkg search [खोज शब्द]
```

Visual Studio के साथ vcpkg का उपयोग करने के लिए,
निम्नलिखित कमांड चलाएं (प्रशासक ऊंचाई की आवश्यकता हो सकती है):

```cmd
> .\vcpkg\vcpkg integrate install
```

इसके बाद, आप अब एक नया गैर-CMake परियोजना बना सकते हैं (या मौजूदा परियोजना खोल सकते हैं।)
सभी स्थापित पुस्तकालयें तुरंत `#include` करने और अपने परियोजना में उपयोग करने के लिए तैयार हैं
और कोई अतिरिक्त विन्यास की आवश्यकता नहीं है।

यदि आप Visual Studio के साथ CMake का उपयोग कर रहे हैं,
तो [यहां](#visual-studio-के-साथ-vcpkg-cmake-परियोजनाएँ) जारी रखें।.

एक IDE के बाहर CMake के साथ vcpkg का उपयोग करने के लिए,
आप टूलचेन फ़ाइल का उपयोग कर सकते हैं:

```cmd
> cmake -B [build directory] -S . "-DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake"
> cmake --build [build directory]
```

CMake के साथ, आपको फिर से `find_package` और आदि की आवश्यकता होगी ताकि आप पुस्तकालयों का उपयोग कर सकें।
और अधिक जानकारी के लिए [CMake अनुभाग](#cmake-के-साथ-vcpkg-का-उपयोग-करना) देखें,
एक IDE के साथ CMake का उपयोग करने के साथ संबंधित जानकारी के बारे में।

## त्वरित प्रारंभ: Unix

Linux के लिए आवश्यकताएँ:
- [Git][getting-started:git]
- [g++][getting-started:linux-gcc] >= 6

MacOS  के लिए आवश्यकताएँ:
- [Apple Developer Tools][getting-started:macos-dev-tools]

सबसे पहले, vcpkg खुद को डाउनलोड करें और bootstrap करें; यह कहीं भी स्थापित किया जा सकता है,
लेकिन आमतौर पर हम vcpkg का उपयोग एक सबमॉड्यूल के रूप में करने की सिफारिश करते हैं।

```sh
$ git clone https://github.com/microsoft/vcpkg
$ ./vcpkg/bootstrap-vcpkg.sh
```

अपने परियोजना के लिए पुस्तकालयों को स्थापित करने के लिए, निम्नलिखित कमांड चलाएं:

```sh
$ ./vcpkg/vcpkg install [स्थापित करने के लिए पैकेज]
```

आप आवश्यक पुस्तकालयों के लिए `search` सबकमांड के साथ खोज भी कर सकते हैं:

```sh
$ ./vcpkg/vcpkg search [खोज शब्द]
```

CMake के साथ vcpkg का उपयोग करने के लिए, आप टूलचेन फ़ाइल का उपयोग कर सकते हैं:

```sh
$ cmake -B [निर्माण निर्देशिका] -S . "-DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake"
$ cmake --build [निर्माण निर्देशिका]
```

CMake के साथ, आपको फिर से पुस्तकालयों का उपयोग करने के लिए `find_package` और उसी तरह की चीजों की आवश्यकता होगी।
vcpkg का CMake के साथ सबसे अच्छा तरीके से उपयोग कैसे करें, और VSCode के लिए CMake टूल्स के बारे में अधिक जानकारी के लिए, [CMake अनुभाग](#cmake-के-साथ-vcpkg-का-उपयोग-करना) देखें।

## Linux Developer Tools स्थापित करना

Linux के विभिन्न डिस्ट्रोज़ के बीच, आपको विभिन्न पैकेज स्थापित करने की आवश्यकता होगी:


- Debian, Ubuntu, popOS, और अन्य Debian-आधारित डिस्ट्रीब्यूशन:

```sh
$ sudo apt-get update
$ sudo apt-get install build-essential tar curl zip unzip
```

- CentOS

```sh
$ sudo yum install centos-release-scl
$ sudo yum install devtoolset-7
$ scl enable devtoolset-7 bash
```

किसी भी अन्य डिस्ट्रीब्यूशन के लिए, सुनिश्चित करें कि आप g++ 6 या उससे ऊपर का स्थापित कर रहे हैं।
यदि आप अपने विशिष्ट डिस्ट्रो के लिए निर्देशन जोड़ना चाहते हैं,
तो कृपया एक पीआर खोलें: [PR दर्ज करें][contributing:submit-pr]!

## MacOS Developer Tools स्थापित करना

macOS पर, आपको केवल इसे अपने टर्मिनल में निम्नलिखित को चलाने की आवश्यकता होगी:

```sh
$ xcode-select --install
```

फिर उन विंडोज़ के साथ आने वाले प्रॉम्प्ट्स के साथ आगे बढ़ें।

फिर आप vcpkg को bootstrap कर सकेंगे, साथ ही [त्वरित प्रारंभ गाइड](#त्वरित-प्रारंभ-unix) के साथ।

## CMake के साथ vcpkg का उपयोग करना

### CMake Tools के साथ विज़ुअल स्टूडियो कोड

अपने कार्यस्थल `settings.json` में निम्नलिखित को जोड़ने से
CMake Tools स्वचालित रूप से पुस्तकालयों के लिए vcpkg का उपयोग करेंगे:

```json
{
  "cmake.configureSettings": {
    "CMAKE_TOOLCHAIN_FILE": "[vcpkg root]/scripts/buildsystems/vcpkg.cmake"
  }
}
```

### Visual Studio के साथ Vcpkg CMake परियोजनाएँ

CMake सेटिंग्स संपादक खोलें, और `CMake टूलचेन फ़ाइल` के तहत,
vcpkg टूलचेन फ़ाइल के पथ को जोड़ें:

```
[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

### CLion के साथ Vcpkg

टूलचेन सेटिंग्स खोलें
(Windows और Linux पर File > Settings, macOS पर CLion > Preferences),
और CMake सेटिंग्स पर जाएं (Build, Execution, Deployment > CMake).
आखिरकार, `CMake options` में, निम्नलिखित पंक्ति जोड़ें:

```
-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

आपको हर प्रोफ़ाइल में इस पंक्ति को जोड़नी होगी।

### CMake के साथ Vcpkg के रूप में एक सबमॉड्यूल के रूप में

जब आप अपने परियोजना के एक सबमॉड्यूल के रूप में vcpkg का उपयोग कर रहे हैं,
तो आपको CMakeLists.txt में पहले `project()` कॉल के पहले निम्नलिखित को जोड़ सकते हैं,
बजाय `CMAKE_TOOLCHAIN_FILE` को cmake कॉल को पास करने के.

```cmake
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake"
  CACHE STRING "Vcpkg टूलचेन फ़ाइल")
```

यह लोगों को अब भी vcpkg का उपयोग नहीं करने देगा,
बिना किसी माध्यम से `CMAKE_TOOLCHAIN_FILE` पास करने के,
लेकिन यह विन्यस के स्थापना-निर्माण कदम को थोड़ा सा आसान बना देगा।

[getting-started:using-a-package]: https://learn.microsoft.com/vcpkg/examples/installing-and-using-packages
[getting-started:git]: https://git-scm.com/downloads
[getting-started:cmake-tools]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools
[getting-started:linux-gcc]: #installing-linux-developer-tools
[getting-started:macos-dev-tools]: #installing-macos-developer-tools
[getting-started:macos-brew]: #installing-gcc-on-macos
[getting-started:macos-gcc]: #installing-gcc-on-macos
[getting-started:visual-studio]: https://visualstudio.microsoft.com/

# टैब-सम्पूर्णता/स्वचलन-सम्पूर्णता

`vcpkg` powershell और bash दोनों में कमांड, पैकेज नामों,
और विकल्पों की स्वचलन-सम्पूर्णता का समर्थन करता है।
अपनी पसंदीदा शैली के शैल में टैब-सम्पूर्णता को सक्षम करने के लिए, निम्नलिखित कमांड चलाएं:

```pwsh
> .\vcpkg integrate powershell
```

या

```sh
$ ./vcpkg integrate bash # या zsh
```

जिस शैल का आप उपयोग करते हैं, उस आधार पर चुनें, फिर अपनी कंसोल को दोबारा चालने के लिए पुनः आरंभ करें।

# उदाहरण

विशिष्ट वॉकथ्रू के लिए [दस्तावेज़ीकरण](https://learn.microsoft.com/vcpkg) देखें,
जिसमें [पैकेज को स्थापित करना और उसका उपयोग करना](https://learn.microsoft.com/vcpkg/examples/installing-and-using-packages),
[जिपफ़ाइल से नया पैकेज जोड़ना](https://learn.microsoft.com/vcpkg/examples/packaging-zipfiles),
और [एक GitHub रेपो से नया पैकेज जोड़ना](https://learn.microsoft.com/vcpkg/examples/packaging-github-repos) शामिल है।

हमारी दस्तावेज़ अब हमारी वेबसाइट https://vcpkg.io/ पर भी उपलब्ध हैं। हम किसी भी प्रतिक्रिया की आकांक्षा करते हैं! आप https://github.com/vcpkg/vcpkg.github.io/issues में एक मुद्दा प्रस्तुत कर सकते हैं।

एक 4 मिनट की [वीडियो डेमो](https://www.youtube.com/watch?v=y41WFKbQFTw) देखें।

# योगदान

Vcpkg एक ओपन सोर्स प्रोजेक्ट है, और इसलिए यह आपके योगदानों के साथ बना जाता है।
यहां कुछ तरीके हैं जिनसे आप योगदान कर सकते हैं:

* [मुद्दे सबमिट करें][contributing:submit-issue] vcpkg या मौजूदा पैकेजों में
* [सुधार और नए पैकेज सबमिट करें][contributing:submit-pr]

अधिक विवरण के लिए कृपया हमारे [योगदान गाइड](CONTRIBUTING.md) का संदर्भ दें।

इस प्रोजेक्ट ने [माइक्रोसॉफ्ट ओपन सोर्स कोड ऑफ कंडक्ट](contributing:coc) को अपनाया है।
और अधिक जानकारी के लिए [कंडक्ट ऑफ कंडक्ट FAQ](contributing:coc-faq)
देखें या [opencode@microsoft.com](mailto:opencode@microsoft.com) पर कोई और प्रश्न या टिप्पणियों के लिए ईमेल करें।

[contributing:submit-issue]: https://github.com/microsoft/vcpkg/issues/new/choose
[contributing:submit-pr]: https://github.com/microsoft/vcpkg/pulls
[contributing:coc]: https://opensource.microsoft.com/codeofconduct/
[contributing:coc-faq]: https://opensource.microsoft.com/codeofconduct/

# लाइसेंस

इस रिपॉजिटरी में कोड [MIT लाइसेंस](LICENSE.txt) के तहत लाइसेंस है। पोर्ट्स द्वारा प्रदान की जाने वाली पुस्तकालय
अपने मूल लेखकों के आपकी उपयोग की शर्तों के तहत लाइसेंस की होती है। जहां उपलब्ध हो, vcpkg
संबंधित लाइसेंसों को स्थिति `installed/<triplet>/share/<port>/copyright` में रखता है।

# सुरक्षा

Vcpkg में अधिकांश पोर्ट्स उन पुस्तकालयों को बनाते हैं जिनकी विषयवस्त्रित लाइब्रेरीज को उन पुस्तकालयों के मूल डेवलपरों की पसंदीदा मूल निर्माण प्रणाली का उपयोग करके और उनके आधिकारिक वितरण स्थलों से स्रोत को डाउनलोड करके बनाते हैं। एक फ़ायरवॉल के पीछे उपयोग के लिए, उन पोर्ट्स को डाउनलोड किए जाने वाले कौनसे स्रोत चाहिए, इसका निर्धारण करेगा। यदि आपको इसे "एयर गैप्ड" पर्यावरण में स्थापित करना हो, तो एक ऐसा विचार करें कि एक बार एक "एयर गैप्ड" पर्यावरण के साथ साझा किए जाने वाले [एसेट कैश](https://learn.microsoft.com/vcpkg/users/assetcaching) में स्थापित किया जाए।

# वाद-संग्रह

vcpkg आपके अनुभव को सुधारने में हमारी मदद करने के लिए उपयोग डेटा जमा करता है।
माइक्रोसॉफ्ट द्वारा जुटाए गए डेटा गुमनाम होता है।
आप टेलीमेट्री से विचलन कर सकते हैं द्वारा
- -disableMetrics के साथ bootstrap-vcpkg स्क्रिप्ट चल करके
- vcpkg कमांड लाइन पर --disable-metrics पास करके
- VCPKG_DISABLE_METRICS पर्यावरण चर पर सेट करके

vcpkg टेलीमेट्री के बारे में अधिक पढ़ें: [https://learn.microsoft.com/vcpkg/about/privacy](https://learn.microsoft.com/vcpkg/about/privacy).