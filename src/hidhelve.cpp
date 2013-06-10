/*******************************************************
Horner's HID Helve
  - handle your human interface device.
 
 David A. Horner
 http://dave.thehorners.com/tech-talk/projects-research/455-horners-hidhelve
 12/30/2012
 
 this app uses HIDAPI to interact with HID devices.
 http://www.signal11.us/oss/hidapi/
 this app uses BOOST C++ Libraries: program_options,regex
 http://www.boost.org/ 
 this app uses proposed BOOST log library
 http://boost-log.sourceforge.net/
 this app uses icu4c for unicode regex support.
 http://site.icu-project.org/

 your app listens to the PublishSlot for events.
 if ControlSlot recieves a message, this app exits nicely.
********************************************************/

#include <io.h>
#include <fcntl.h>
#include <string>
#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#ifdef _WIN32
	#include <wchar.h>
	#include <TCHAR.H>
    #include <windows.h>
#else
    #include <unistd.h>
#endif

#include "hidapi.h"
#include <boost/program_options.hpp>
#include <boost/program_options/options_description.hpp>
#include <boost/program_options/parsers.hpp>
#include <boost/program_options/variables_map.hpp>
#include <boost/tokenizer.hpp>
#include <boost/token_functions.hpp>
#include <boost/regex.hpp>

#include <boost/lexical_cast.hpp>
#include <boost/optional.hpp>
#include <boost/format/format_fwd.hpp>
#include <boost/locale/encoding_utf.hpp>
#include <boost/log/core/record.hpp>

#include <boost/regex/icu.hpp>

#include "hidhelve_version.h"
#include "hidhelve_log.h"

using namespace std;
using namespace boost;
using namespace boost::program_options;

BOOL attemptToOpenShop();
void attemptToCloseUpShop(int retval);

#define MAX_STR 2048
#define TIMETOREAD_CONSTANT 10000
// http://stackoverflow.com/questions/111928/is-there-a-printf-converter-to-print-in-binary-format
#define BYTETOBINARYPATTERN "%d%d%d%d%d%d%d%d"
#define BYTETOBINARY(byte)  (byte & 0x80 ? 1 : 0), \
                            (byte & 0x40 ? 1 : 0), \
                            (byte & 0x20 ? 1 : 0), \
                            (byte & 0x10 ? 1 : 0), \
                            (byte & 0x08 ? 1 : 0), \
                            (byte & 0x04 ? 1 : 0), \
                            (byte & 0x02 ? 1 : 0), \
                            (byte & 0x01 ? 1 : 0) 
const wchar_t *theSlotServerName   = TEXT("\\\\.\\mailslot\\hornersHidHelveControlSlot%ls");
const wchar_t *theSlotClientName   = TEXT("\\\\%ls\\mailslot\\hornersHidHelvePublishSlot%ls");
HANDLE         theSlotClientHandle = INVALID_HANDLE_VALUE; 
HANDLE         theSlotServerHandle = INVALID_HANDLE_VALUE; 
hid_device    *theHIDhandle        = 0;
std::wstring   theDomain; 
std::wstring   theProductRegx; 
std::wstring   theDevicePath;
std::wstring   theSubSlotName;
int            theVLevel;
int            theExitCondition;
TCHAR          theLastReportedValue;
options_description general("General");
options_description spec("HID Specification");
options_description mailslots("Mailslot IPC");
options_description desc;

/* Define a completely non-sensical class. 
struct magic_number {
public:
    magic_number(int n) : n(n) {}
    int n;
};

// Holds parameters for seed/expansion model
class Model
{
public:
    std::wstring type;
    boost::optional<float> param1;
    boost::optional<float> param2;
	friend ostream& operator<<(ostream& os, const Model& dt)
	{
		os << dt.type.c_str() <<dt.param1<<dt.param2<<endl;
		return os;
	}
};

// Called by program_options to parse a set of Model arguments
void validate(boost::any& v, const std::vector<std::wstring>& values,
              Model*, int)
{
    Model model;
    // Extract tokens from values string vector and populate Model struct.
    if (values.size() == 0)
    {
//        throw boost::program_options::validation_error(boost::program_options::validation_error::kind_t::invalid_bool_value,L"mo values");
    }
   //model.type = values.at(0); // Should validate for A/B
    if (values.size() >= 2)
        model.param1 = boost::lexical_cast<float>(values.at(1));
    if (values.size() >= 3)
        model.param2 = boost::lexical_cast<float>(values.at(2));

    v = model;
}
*/

/* Overload the 'validate' function for the user-defined class.
   It makes sure that value is of form XXX-XXX 
   where X are digits and converts the second group to an integer.
   This has no practical meaning, meant only to show how
   regex can be used to validate values.

void validate(boost::any& v, 
              const std::vector<std::wstring>& values,
              magic_number*, int)
{
	static u32regex r = make_u32regex("\\d\\d\\d-(\\d\\d\\d)");

    using namespace boost::program_options;

    // Make sure no previous assignment to 'a' was made.
    validators::check_first_occurrence(v);
    // Extract the first string from 'values'. If there is more than
    // one string, it's an error, and exception will be thrown.
    const wstring& s = validators::get_single_string(values);
    // Do regex match and convert the interesting part to 
    // int.
    smatch match;
    if (u32regex_match(boost::locale::conv::utf_to_utf<char>(s).c_str(), match, r)) {
        v = any(magic_number(lexical_cast<int>(match[1])));
    } else {
        throw validation_error(validation_error::invalid_option_value);
    }        
}
namespace Length { enum Unit {METER, INCH};};

typedef std::vector<Length::Unit> UnitList;

std::istream& operator>>(std::istream& in, Length::Unit& unit)
{
    std::string token;
    in >> token;
    if (token == "inch")
        unit = Length::INCH;
    else if (token == "meter")
        unit = Length::METER;
//    else throw boost::program_options::validation_error(std::string("Invalid unit"));
    return in;
}

pair<string, string> reg_foo(const string& s)
{
    if (s.find("-f") == 0) {
        if (s.substr(2, 3) == "no-")
            return make_pair(s.substr(5), string("false"));
        else
            return make_pair(s.substr(2), string("true"));
    } else {
        return make_pair(string(), string());
    }    
}

*/

pair<string, string> at_option_parser(string const&s)
{
    if ('@' == s[0])
        return std::make_pair(string("response-file"), s.substr(1));
    else
        return pair<string, string>();
}

// trap ctrl-c and exit.
void CtrlCIntHandler(int sig)
{
    signal(sig, SIG_IGN);
    attemptToCloseUpShop(69);
}
void DisplayHelp(void)
{
		cout << "Horner's HIDHelve - handle your human interface device.\n";
		cout << "your app listens to the PublishSlot for events or reads from my STDOUT.\n";
		cout << "if ControlSlot recieves a message, I exit nicely.\n"; 
        cout << desc ;
		Sleep(TIMETOREAD_CONSTANT);
}

int wmain(int argc, _TCHAR* argv[])
{
    _TCHAR wstr[MAX_STR];
    unsigned char buf[MAX_STR];
    struct hid_device_info *devs, *cur_dev;
    DWORD cbWritten,cbMessage, cMessage;	

    bool theListMode=false;
    signal(SIGINT, CtrlCIntHandler);
	/*_setmode(_fileno(stdout), _O_U16TEXT);
	SetConsoleOutputCP(CP_UTF8);*/

    LOG_INFO("compiled: "<<__DATE__<<" at "<<__TIME__)
    LOG_DEBUG("_INTEGRAL_MAX_BITS?"<<_INTEGRAL_MAX_BITS)
    LOG_DEBUG("_MSC_VER?"<<_MSC_VER)
    LOG_DEBUG("_CPPLIB_VER?"<<_CPPLIB_VER)
#ifdef _DEBUG
    LOG_DEBUG("_DEBUG?"<<_DEBUG)
#endif
    LOG_DEBUG("_NATIVE_WCHAR_T_DEFINED?"<<_NATIVE_WCHAR_T_DEFINED)
    LOG_DEBUG("_WCHAR_T_DEFINED?"<<_WCHAR_T_DEFINED)
    // wstrings are a little tricky to default_value, lucky we have Sahab and stackoverflow.
    // http://stackoverflow.com/questions/6921196/in-boostprogram-options-how-to-set-default-value-for-wstring
    //
	/*
	Model seedModel, expansionModel;
    UnitList units;
	*/
    general.add_options()
        ("listmode,l" , bool_switch(&theListMode), "list devices on system and exit")
        ("help,h"     , "produce this help message")
        ("verbose,v"  , value<int>(&theVLevel)->default_value(1), "verbosity level")
        ("exitvalue,e", value<int>(&theExitCondition)->default_value(-1), "termination value indicates when to exit (-1=none)")
        ("response-file,r", value<string>(),"set settings from rsp file, @pathto.rsp also valid syntax.")
//        ("to-unit,t", value<UnitList>(&units)->multitoken(),"The unit(s) of length to convert to")
//        ("seed",value<Model>(&seedModel)->multitoken(),"seed graph model")
//        ("expansion",value<Model>(&expansionModel)->multitoken(),"expansion model")
        
    ;
    spec.add_options()
        ("Path,P"     , wvalue<std::wstring>(&theDevicePath),"the full HID device path")
        ("product,p"  , wvalue<std::wstring>(&theProductRegx),"regex to match against product")
    ;

    mailslots.add_options()
        ("domain,d"   , wvalue<std::wstring>(&theDomain)->default_value(_T("."), "."), "mailslot IPC domain")		
        ("slotname,s" , wvalue<std::wstring>(&theSubSlotName), "mailslot IPC terminal subslot name (useful for multi-instance)")
//        ("magic,m", value<magic_number>(), "magic value (in NNN-NNN format)")
    ;

    desc.add(general).add(spec).add(mailslots);

    variables_map vm;        
    if (vm.count("response-file")) {
        // Load the file and tokenize it
        ifstream ifs(vm["response-file"].as<string>().c_str());
        if (!ifs) {
        LOG_FATAL("Could no open the response file")
        return 1;
        }
        // Read the whole file into a string
        stringstream ss;
        ss << ifs.rdbuf();
        // Split the file content
        char_separator<char> sep(" \n\r");
        tokenizer<char_separator<char> > tok(ss.str(), sep);
        vector<string> args;
        copy(tok.begin(), tok.end(), back_inserter(args));
        // Parse the file and store the options
        store(command_line_parser(args).options(desc).run(), vm);
    }

    try {
		//.allow_unregistered().extra_parser(reg_foo).run()
        store(wcommand_line_parser(argc, argv).options(desc).allow_unregistered().run(),vm);
        notify(vm);    
    } catch(boost::program_options::invalid_command_line_syntax const&  ex) {
        LOG_ERROR("um, boost::program_options says something isn't quite right.\n" << ex.what())
        Sleep(TIMETOREAD_CONSTANT);
        return 1;
    } catch(std::exception& e) {
        LOG_ERROR(e.what())
    }    
/*
	LOG_INFO(_T("Seed type: ") << seedModel.type)
    if (seedModel.param1)
        LOG_INFO(_T("Seed param1: ") << *(seedModel.param1))
    if (seedModel.param2)
        LOG_INFO(_T("Seed param2: ") << *(seedModel.param2))

    LOG_INFO("Expansion type: " << expansionModel.type)
    if (expansionModel.param1)
        LOG_INFO("Expansion param1: " << *(expansionModel.param1))
    if (expansionModel.param2)
        LOG_INFO("Expansion param2: " << *(expansionModel.param2))
    if (vm.count("magic")) {
        LOG_INFO("The magic is \"" << vm["magic"].as<magic_number>().n << "\"")
    }

*/

    if (vm.count("help")) {
		DisplayHelp();
    }

    LOG_DEBUG("Verbosity: " << theVLevel)

    if (vm.count("product")) {
        LOG_INFO("Product RegEx: "<<theProductRegx.c_str())
    }

    _snwprintf_s(wstr,MAX_STR,theSlotClientName, theDomain.c_str(), theSubSlotName.c_str());
    LOG_INFO("PublishSlot: "<<wstr)
    _snwprintf_s(wstr,MAX_STR,theSlotServerName, theDomain.c_str(), theSubSlotName.c_str());
    LOG_INFO("ControlSlot: "<<wstr)

    theSlotServerHandle=CreateMailslot(wstr,0,0,(LPSECURITY_ATTRIBUTES)NULL);
    if (theSlotServerHandle == INVALID_HANDLE_VALUE) 
    { 
        LOG_ERROR("error opening, you may have me running already. GetLastError:"<<GetLastError())
        Sleep(TIMETOREAD_CONSTANT);
        return 2; 
    }

    if (hid_init()) {
        LOG_FATAL("trouble in the land of hid.")
        return -1;
    }
    if(vm.count("exitvalue"))
        LOG_INFO("theExitCondition="<<theExitCondition)
    
    if(vm.count("Path")) {
        char mbpath[MAX_STR];
        size_t mbbytes;
        if(wcstombs_s(&mbbytes,mbpath,MAX_STR,theDevicePath.c_str(),_TRUNCATE)==0) {
            LOG_INFO("Path Set OPENING "<<mbpath)
            theHIDhandle = hid_open_path(mbpath);		
        }
    }

    if((theProductRegx.length()>0 || theListMode) && !theHIDhandle) {
		unsigned short search_vendor_id=0x0;
		unsigned short search_product_id=0x0;
        cur_dev=devs=hid_enumerate(search_vendor_id, search_product_id);
        while (cur_dev) {
            BOOL devicematch=wcsstr(cur_dev->product_string,theProductRegx.c_str())!=NULL;
            if(devicematch || theListMode) {
                printf("path: %s\n  serial_number: %ls\n", cur_dev->path, cur_dev->serial_number);
                printf("  Manufacturer: %ls\n", cur_dev->manufacturer_string);
                printf("  Product:      %ls\n", cur_dev->product_string);
                printf("  Type: %04hx %04hx\n  Release:      %hx\n",cur_dev->vendor_id, cur_dev->product_id, cur_dev->release_number);
                printf("  Interface:    %d\n",  cur_dev->interface_number);
                printf("\n");
            }
            if(devicematch && !theListMode) {
                LOG_INFO("OPENING "<<cur_dev->path)
                theHIDhandle = hid_open_path(cur_dev->path);
                break;
            }
            cur_dev = cur_dev->next;
        }
        hid_free_enumeration(devs);
    }

    if(theListMode) {
        return 0;
    }

    if (!theHIDhandle) {
		DisplayHelp();
        return 3;
    }

    cout<<"current(hex),current(binary),current^prior(hex),current^prior(bin)"<<endl;
    while(1) {
        if(hid_read_timeout(theHIDhandle, buf, 17,500)>0) {
            _TCHAR xord=theLastReportedValue^buf[0];
            theLastReportedValue=buf[0];
            for (int i = 0; i < 1; i++)
                _snwprintf_s(wstr,MAX_STR,_T("%02hhx,")_T(BYTETOBINARYPATTERN)_T(",%02hhx,")_T(BYTETOBINARYPATTERN), buf[i],BYTETOBINARY(buf[i]),xord,BYTETOBINARY(xord));
            wcscat_s(wstr,MAX_STR,_T("\n"));
            _tprintf(wstr);
            for(int attempts=0;attempts<2;attempts++) {				
                if(theSlotClientHandle==INVALID_HANDLE_VALUE)
                    attemptToOpenShop();
                if(theSlotClientHandle!=INVALID_HANDLE_VALUE) {
                    if (WriteFile(theSlotClientHandle,wstr,(DWORD)_tcslen(wstr)*sizeof(TCHAR),&cbWritten,(LPOVERLAPPED)NULL)) { 
                        break;
                    } else
                        theSlotClientHandle=INVALID_HANDLE_VALUE;
                }
            }
            if(buf[0]==theExitCondition) {
                break;
            }
        }
        if(GetMailslotInfo(theSlotServerHandle,(LPDWORD)NULL,&cbMessage,&cMessage,(LPDWORD)NULL) && cbMessage!=-1) {
            break;
        } 
    }
    attemptToCloseUpShop(0);
    return 0; //attemptToCloseUpShop exit()s.
}

BOOL attemptToOpenShop()
{
    _TCHAR wstr[MAX_STR];
    _snwprintf_s(wstr,MAX_STR,theSlotClientName, theDomain.c_str(), theSubSlotName.c_str());
    LOG_INFO("attempting to open PublishSlot: "<<wstr)
    theSlotClientHandle = CreateFile(wstr, GENERIC_WRITE, FILE_SHARE_READ,(LPSECURITY_ATTRIBUTES)NULL,
									CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,(HANDLE)NULL);  
    if (theSlotClientHandle == INVALID_HANDLE_VALUE) { 
        LOG_ERROR("open failed, perhaps there aren't any listeners?")
        return FALSE; 
    }
    return TRUE;
}

void attemptToCloseUpShop(int retval)
{
    LOG_DEBUG("going down.")
    if(theSlotClientHandle!=INVALID_HANDLE_VALUE)
        CloseHandle(theSlotClientHandle); 
    if(theSlotServerHandle!=INVALID_HANDLE_VALUE)
        CloseHandle(theSlotServerHandle); 
    hid_close(theHIDhandle);
    hid_exit();
    exit(retval);								  
}
