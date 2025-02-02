//+------------------------------------------------------------------+
//|                                                      Helpers.mqh |
//|                                               R. Martín Parrondo |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "R. Martín Parrondo"
#property link "https://www.mql5.com"

#include <Mql/Lang/Mql.mqh>  //ram
#include <Zmq/Zmq.mqh>
#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Trade/AccountInfo.mqh>

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

#define MODE_LOW  1  // Minimum day price
#define MODE_HIGH    2  // Maximum day price
#define MODE_TIME    5  // The last incoming tick time.
#define MODE_BID    9  // Last incoming bid price. For the current symbol, it is stored in the predefined variable Bid.
#define MODE_ASK    10    // Last incoming ask price. For the current symbol, it is stored in the predefined variable Ask.
#define MODE_POINT  11    // Point size in the quote currency. For the current symbol, it is stored in the predefined variable Point.
#define MODE_DIGITS    12    // Count of digits after decimal point in the symbol prices. For the current symbol, it is stored in the predefined variable Digits.
#define MODE_SPREAD    13    // Spread value in points.
#define MODE_STOPLEVEL    14    // Minimal permissible StopLoss/TakeProfit value in points.
#define MODE_LOTSIZE   15    // Lot size in the base currency.
#define MODE_TICKVALUE    16    // Minimal tick value in the deposit currency.
#define MODE_TICKSIZE  17    // Minimal tick size in the quote currency.
#define MODE_SWAPLONG  18    // Swap of a long position.
#define MODE_SWAPSHORT    19    // Swap of a short position.
#define MODE_STARTING  20    // Trade starting date (usually used for futures).
#define MODE_EXPIRATION   21    // Trade expiration date (usually used for futures).
#define MODE_TRADEALLOWED    22    // Trade is allowed for the symbol.
#define MODE_MINLOT    23    // Minimal permitted lot size.
#define MODE_LOTSTEP   24    // Step for changing lots.
#define MODE_MAXLOT    25    // Maximal permitted lot size.
#define MODE_SWAPTYPE  26    // Swap calculation method. 0 - in points; 1 - in the symbol base currency; 2 - by interest; 3 - in the margin currency.
#define MODE_PROFITCALCMODE  27    // Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures.
#define MODE_MARGINCALCMODE  28    //Margin calculation mode. 0 - Forex; 1 - CFD; 2 - Futures; 3 - CFD for indexes.
#define MODE_MARGININIT   29    // Initial margin requirements for 1 lot.
#define MODE_MARGINMAINTENANCE  30    // Margin to maintain open positions calculated for 1 lot.
#define MODE_MARGINHEDGED    31    // Hedged margin calculated for 1 lot.
#define MODE_MARGINREQUIRED  32    // Free margin required to open 1 lot for buying.
#define MODE_FREEZELEVEL  33    // Order freeze level in points. If the execution price lies within the range defined by the freeze level, the order cannot be modified, canceled or closed.

//ENUM_TIMEFRAMES
#define _PERIOD_M1 1
#define _PERIOD_M2 2
#define _PERIOD_M3 3
#define _PERIOD_M4 4
#define _PERIOD_M5 5
#define _PERIOD_M6 6
#define _PERIOD_M10 7
#define _PERIOD_M12 8
#define _PERIOD_M15 9
#define _PERIOD_M20 10
#define _PERIOD_M30 11
#define _PERIOD_H1 12
#define _PERIOD_H2 13
#define _PERIOD_H3 14
#define _PERIOD_H4 15
#define _PERIOD_H6 16
#define _PERIOD_H8 17
#define _PERIOD_H12 18
#define _PERIOD_D1 19
#define _PERIOD_W1 20
#define _PERIOD_MN1 21
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// int PostMessageA(int hWnd, int Msg, int wParam, string lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import

//+------------------------------------------------------------------+
///                       Market Block                               |
//+------------------------------------------------------------------+
//////////////////////////////////////////////////////////////////////
//+------------------------------------------------------------------+
/// Examine an instrument
//+------------------------------------------------------------------+
void Examine(string symbol = "EURUSD")
  {
   double dLotFactor = MarketInfo(symbol,MODE_MINLOT); // correction for different lot scale
   double dFactor = pointFactor(symbol); // correction for brokers with 5 digits
   Print("Examining");
   PrintFormat("%s  Price %.5f  Spread %.5f",
               symbol,MarketInfo(symbol,MODE_ASK),MarketInfo(symbol,MODE_ASK)-MarketInfo(symbol,MODE_BID));
   PrintFormat("%s  Point %.5f  Digits %.0f  PIP %.5f",
               symbol,MarketInfo(symbol,MODE_POINT),MarketInfo(symbol,MODE_DIGITS),MarketInfo(symbol,MODE_POINT)*dFactor);
   PrintFormat("%s  Tick %.5f  TickVal %.5f",
               symbol,MarketInfo(symbol,MODE_TICKSIZE),MarketInfo(symbol,MODE_TICKVALUE));
   PrintFormat("%s  LotMin %.2f  LotSize %.2f  LotAmount %.2f",
               symbol,dLotFactor,MarketInfo(symbol,MODE_LOTSIZE),MarketInfo(symbol,MODE_LOTSIZE)*dLotFactor);
   PrintFormat("%s  PipCost %.5f  MarginCost %.2f",
               symbol,MarketInfo(symbol,MODE_TICKVALUE) * dLotFactor * dFactor,
               MarketInfo(symbol,MODE_MARGINREQUIRED) * dLotFactor);

   return;
  }
//+------------------------------------------------------------------+
//| Returns various data about securities                                                   |
//+------------------------------------------------------------------+
double MarketInfo(const string symbol, // symbol
                  const int type)      // information type
  {
   switch(type)
     {
      case MODE_LOW:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTLOW));
      case MODE_HIGH:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTHIGH));
      case MODE_TIME:
         return(SymbolInfoInteger(symbol,SYMBOL_TIME));
      case MODE_BID:
         return(SymbolInfoDouble(symbol,SYMBOL_BID));
      case MODE_ASK:
         return(SymbolInfoDouble(symbol,SYMBOL_ASK));
      case MODE_POINT:
         return(SymbolInfoDouble(symbol,SYMBOL_POINT));
      case MODE_DIGITS:
         return(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
      case MODE_SPREAD:
         return(SymbolInfoInteger(symbol,SYMBOL_SPREAD));
      case MODE_STOPLEVEL:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL));
      case MODE_LOTSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE));
      case MODE_TICKVALUE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE));
      case MODE_TICKSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE));
      case MODE_SWAPLONG:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_LONG));
      case MODE_SWAPSHORT:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_SHORT));
      case MODE_STARTING:
         return(0);
      case MODE_EXPIRATION:
         return(0);
      case MODE_TRADEALLOWED:
         if(SymbolInfoInteger(symbol,SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_DISABLED)
            return(0);
         else
            return(1);
      case MODE_MINLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN));
      case MODE_LOTSTEP:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP));
      case MODE_MAXLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX));
      case MODE_SWAPTYPE:
         return(SymbolInfoInteger(symbol,SYMBOL_SWAP_MODE));
      case MODE_PROFITCALCMODE:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE));
      case MODE_MARGINCALCMODE:
         return(0);
      case MODE_MARGININIT:
         return(SymbolInfoDouble(symbol,SYMBOL_MARGIN_INITIAL));
      case MODE_MARGINMAINTENANCE:
         return(SymbolInfoDouble(symbol,SYMBOL_MARGIN_MAINTENANCE));
      case MODE_MARGINHEDGED:
         return(SymbolInfoDouble(symbol,SYMBOL_MARGIN_HEDGED));
      case MODE_MARGINREQUIRED:
         return(MathMax(::SymbolInfoDouble(symbol, ::SYMBOL_MARGIN_INITIAL), //Margin Initial usually only for stocks
                        ::SymbolInfoDouble(symbol, ::SYMBOL_MARGIN_MAINTENANCE)));
      case MODE_FREEZELEVEL:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL));
      default:
         return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int pointFactor(string symbol)
  {
   int DigitSize = (int)MarketInfo(symbol,MODE_DIGITS); // correction for brokers with 5 or 6 digits
   if(DigitSize == 3 || DigitSize == 5)
      return(10);
   else
      if(DigitSize == 6)
         return(100);
      else
         return(1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LogAccount(int t)
  {
   static uint LastLog = 0;
   if(GetTickCount() > LastLog + t*60*1000)
     {
      LastLog = GetTickCount();
      PrintFormat("\nBal %.2f  Equ %.2f  Mrg %.2f",
                  AccountBalance(),AccountEquity(),AccountMargin());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountEquity(void)
  {
   return(::AccountInfoDouble(::ACCOUNT_EQUITY));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountMargin(void)
  {
   return(::AccountInfoDouble(::ACCOUNT_MARGIN));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountBalance()
  {
   return(::AccountInfoDouble(ACCOUNT_BALANCE));
  }
//+------------------------------------------------------------------+
///                Initial Checking Block                            |
//+------------------------------------------------------------------+
//////////////////////////////////////////////////////////////////////
//+------------------------------------------------------------------+
/// Initial checking the working conditions.
//+------------------------------------------------------------------+
void InitialChecking(string _examine="", int _logAccount=0, string _authAccounts="", bool _checkAccounts=true, bool _writeLogFile=false, string _ver="")
  {
// Welcome messages
   string message = "JsonAPI loaded. An initial test is running...";
   Comment(message);
   Print(message);

// Some symbol properties for testing
   if(!(_examine==""))
      Examine(_examine);

   if(_logAccount>0)
      LogAccount(_logAccount);

// Checks the requirements.
   if(_checkAccounts) {
      bool isEnvironmentGood = CheckEnvironment(_authAccounts);
      if(!isEnvironmentGood)
        {
         // There is a nonfulfilled condition, so exit.
         Sleep(1 * 1000);
         Alert("Unacceptable Terminal state check EA messages and start over");
         Print(TimeCurrent(),": JsonAPI Expert Advisor will be removed");
         ExpertRemove();
        }
      
         if(_writeLogFile)
           {
            CreateLogFile(GetLogFileName());
            WriteLogLine("Expert version " + _ver + " Loaded.");
            WriteLogLine("ZEROMQ_PROTOCOL =" + ZEROMQ_PROTOCOL +
                         ", HOST =" + HOST +
                         ", SYS_PORT =" + SYS_PORT +
                         ", DATA_PORT =" + DATA_PORT +
                         ", LIVE_PORT =" + LIVE_PORT +
                         ", STR_PORT =" +STR_PORT +
                         ", MILLISECOND_TIMER =" + MILLISECOND_TIMER +
                         ", authAccounts =" + authAccounts +
                         ", writeLogFile =" + writeLogFile +
                         ", logAccount =" +logAccount +
                         ", liveData =" + liveData);
   
            FlushLogFile();
           }
      
   } else {
     bool isEnvironmentGood = true;
   }
   
   message = "The environment test was accomplished successfully.";
   Comment(message);
   Print(message);
   return;
  }
//+------------------------------------------------------------------+
/// Checks the working conditions.
//+------------------------------------------------------------------+
bool CheckEnvironment(string _authAccounts)
  {
   string message;

// Checks if DLL is allowed.
//ram if (TerminalInfoInteger(TERMINAL_DLLS_ALLOWED) == false)
   if(Mql::isDllAllowed() == false)
     {
      message = "\n" + "DLL call is not allowed." + "\n" +
                "Please allow DLL loading in the MT options and restart the expert.";
      Comment(message);
      Print(message);
      return (false);
     }

// Checks ZMQ Library version
   int major;
   int minor;
   int patch;
   zmq_version(major, minor, patch);
   PrintFormat("Current ØMQ version is %d.%d.%d\n", major, minor, patch);

   string versionString = IntegerToString(major) + "." + IntegerToString(minor) + "." + IntegerToString(patch);
   if(versionString != "")
     {
      message = "libzmq version " + versionString + " loaded successfully.";
      Comment(message);
      Print(message);
     }
   else
      // Meta Trader terminal stops if it cannot load the dll.
     {
      message = "\n" + "Cannot load \"libzmq.dll\"." + "\n";
      Comment(message);
      Print(message);
      return (false);
     }

// Checks if you are logged in.
   if(CheckLoggingAccount(_authAccounts) == 0)
     {
      message = "\n" + "You are not logged in. Please login first.";
      Print(message);
      for(int attempt = 0; attempt < 10; attempt++)
        {
         if(CheckLoggingAccount(_authAccounts) == 0)
            Sleep(5000);
         else
            break;
        }
      if(CheckLoggingAccount(_authAccounts) == 0)
        {
         return (false);
        }
     }

// Everything looks OK.
   return (true);
  }
//+------------------------------------------------------------------+
//| Account Logging in Checking
//+------------------------------------------------------------------+
bool CheckLoggingAccount(string my_accounts)
  {
//Checks if you are logged. Several accounts are allowed.

// Parse accounts string
   string separator = ",";
   long accounts[];
   StringToLongArray(my_accounts, separator, accounts);

   long my_acc = (long)AccountInfoInteger(ACCOUNT_LOGIN);
   bool is_auth = false;

   for(int i = 0; i < ArraySize(accounts); i++)
      if((long)accounts[i] == (long)my_acc)
        {
         is_auth = true;
         Print("Your account ", accounts[i], " is authorized");
        }

   if(!is_auth)
     {
      Print("Account not authorized!");
      return (false);
     }
   else
     {
      return (true);
     }
  }
//+----------------------------------------------------------------------------+
//| void StringToLongArray(string toSplit, string separator=",", int &a[])
//+----------------------------------------------------------------------------+
// Breaks down a single string into long array 'a' (elements delimited by
// 'separator')
//  e.g. string is "1,2,3,4,5";  if separator is "," then the result will be
//  a[0]=1   a[1]=2   a[2]=3   a[3]=4   a[4]=5
//+----------------------------------------------------------------------------+
int StringToLongArray(string toSplit, string separator, long &a[])
  {
   ushort uSep = StringGetCharacter(separator, 0);
   string result[];
   int k = StringSplit(toSplit, uSep, result);

//--- Show comment
   PrintFormat("Get the following strings: %d. Used separator is '%s' with code %d", k, separator, uSep);
//--- ahora visualizamos todas las cadenas obtenidas
   if(k > 0)
     {
      ArrayResize(a, k, 0);
      for(int i = 0; i < k; i++)
        {
         a[i] = (long)StringToInteger(result[i]);
        }
     }
   else
     {
      //TODO: Error handler
     }
   return (k);
  }
//+------------------------------------------------------------------+
//| Return a textual description of the deinitialization reason code |
//+------------------------------------------------------------------+
string getUninitReasonText(int reasonCode)
  {
   string text="";
//---
   switch(reasonCode)
     {
      case REASON_PROGRAM://0
         text="The EA has stopped working calling the ExpertRemove() function";
         break;
      case REASON_REMOVE://1
         text="EA JSsonAPI was removed from chart";
         break;
      case REASON_RECOMPILE://2
         text="EA JSsonAPI was recompiled";
         break;
      case REASON_CHARTCHANGE://3
         text="Symbol or timeframe was changed";
         break;
      case REASON_CHARTCLOSE://4
         text="Chart was closed";
         break;
      case REASON_PARAMETERS://5
         text="Input-parameter was changed";
         break;
      case REASON_ACCOUNT://6
         text="Account was changed";
         break;
      case REASON_TEMPLATE://7
         text="New template was applied to chart";
         break;
      case REASON_INITFAILED://8
         text="The OnInit() handler returned a non-zero value";
         break;
      case REASON_CLOSE://9
         text="Terminal closed";
         break;
      default:
         text="Another reason";
     }
//---
   return text;
  }
//+------------------------------------------------------------------+
//|               Logging File Management Block                      |
//+------------------------------------------------------------------+
//////////////////////////////////////////////////////////////////////
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetLogFileName()
  {
   string time = _StringReplace(TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS), ":", "");
   time = _StringReplace(time, " ", "_");
   string fileName = Symbol() + "_" + Period() +"_" + magicNumber + "_" + time +".log";

   return (fileName);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CreateLogFile(string fileName)
  {
   logLines = 0;
   int handle = FileOpen(fileName, FILE_WRITE|FILE_CSV, ",");
   if(handle > 0)
      _fileHandle = handle;
   else
      Print("CreateFile: Error while creating log file!");
   return (handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteLogLine(string text)
  {
   if(_fileHandle <= 0)
      return;
   FileWrite(_fileHandle, TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS), text);
   logLines++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteNewLogLine(string text)
  {
   if(_fileHandle <= 0)
      return;
   FileWrite(_fileHandle, "");
   FileWrite(_fileHandle, TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS), text);
   logLines += 2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseLogFile()
  {
   if(_fileHandle <= 0)
      return;
   WriteNewLogLine("MT4-FST Expert version " + EXPERT_VERSION + " Closed.");
   FileClose(_fileHandle);
  }
//+------------------------------------------------------------------+
// Search for the string needle in the string haystack and replace all
// occurrences with replace.
//+------------------------------------------------------------------+
string _StringReplace(string haystack, string needle, string replace)
  {
   string left, right;
   int start=0;
   int rlen = StringLen(replace);
   int nlen = StringLen(needle);
   while(start > -1)
     {
      start = StringFind(haystack, needle, start);
      if(start > -1)
        {
         if(start > 0)
           {
            left = StringSubstr(haystack, 0, start);
           }
         else
           {
            left="";
           }
         right = StringSubstr(haystack, start + nlen);
         haystack = left + replace + right;
         start = start + rlen;
        }
     }
   return (haystack);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FlushLogFile()
{
    if (_fileHandle <= 0) return;
    FileFlush(_fileHandle);
}
