//+-------------------------------------------+
//|                      Blackrain Trend      |
//|                 Property of: Elio Pajares |
//|                   v0.0.1   28 - 03 - 2021 |
//+-------------------------------------------+
#property description "Blackrain Trend 0.0.1"
#property copyright   "Copyright © 2021, Elio Pajares"
//#property link        "http://www.blackrainalgo.com"

//+------------------------------------------------------------------+
//| DESCRIPTION                                                      |
//+------------------------------------------------------------------+

//##########################################
//## Walk Forward Pro Header Start (MQL4) ##
//##########################################
//#import "TSMWFP.ex4"
//void WFA_Initialise();
//void WFA_UpdateValues();
//void WFA_PerformCalculations(double &dCustomPerformanceCriterion);
//#import
//########################################
//## Walk Forward Pro Header End (MQL4) ##
//########################################

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                 |
//+------------------------------------------------------------------+


input int    magic_number  = 12345 ; //change magic number when same EA used in the same account to avoid overlap issues with open orders
//input string pair          = "EURUSD"; //currency pair

extern string  data_1 = "==== SL, TP, TS ====";
input bool     AllowOrders   = true;
input int      orders        = 1;
input int      spread        = 20; // value in points
//input double   StopLoss      = 20; // SL is used Lotsize calculation via % balance at risk
//input double   TakeProfit    = 40; // TP is unlimited
input          ENUM_TIMEFRAMES LOW_TF = PERIOD_H1;
input          ENUM_TIMEFRAMES MED_TF = PERIOD_H4;
input          ENUM_TIMEFRAMES HIGH_TF = PERIOD_D1;
input int      time_between_trades = -1; //value in seconds of the time between a loss trade and a new one,  -1 for not using this

extern string  data_2 = "==== Management of trade setup ====";
input bool     pyramidying = false;
input int      max_pyramid_trades = 3;
input bool     management_trade = false; //
input bool     breakeven     = false;
input bool     close_trade     = true;
input bool     trailing      = false; //
input double   TrailingStop  = 20; //
input double   TS_RRratio_step = 2; //TS step in regards RR ratio
input double   TS_RRratio_sl = 1; //TS stoploss distance in regards RR ratio
input bool     CloseOnDuration = false;
input int      MaxDurationHours = 1000; //in hours
input int      MaxDurationMin   = 0; //in minutes
input bool     CloseFridays    = false;
input bool     retrace         = false;
input double   PipsStick     = 40;
input double   PipsRetrace   = 20;

extern string  data_3 = "==== Money management ====";
input double   Lots         = 0.1;
input bool     MM           = true;
input double   Risk         = 0.5;
input double   RR           = 2;
input double   maxlots      = 2;

extern string  data_4 = "==== Entry & Exit parameters ====";
input bool     S1             = true;
input int      Trade_Period_S1= 20;
input int      Stop_Period_S1 = 10;
input bool     S2             = true;
input int      Trade_Period_S2= 55;
input int      Stop_Period_S2 = 20;
input bool     Strict         = false;

extern string  data_5 = "==== ATR parameters ====";
input int      ATR_period     = 20;
input double   ATR_SL_factor  = 2;

extern string  data_6 = "==== Stochastic parameters ====";
input int      KPeriod        = 14; // K Period
input int      DPeriod        = 7; // D Period
input int      Slowing        = 9;  // Slowing value
//input int      StochUpper     = 70; // Stochastic Upper limit
//input int      StochLower     = 30; // Stochastic Lower limit
input int      Stoch_range    = 30;

extern string  data_8 = "==== Days to Trade ====";
input bool     Sunday         = true;
input bool     Monday         = true;
input bool     Tuesday        = true;
input bool     Wednesday      = true;
input bool     Thursday       = true;
input bool     Friday         = true;

extern string  data_9 = "==== Hours to Trade ====";
input int      StartHourTrade = 0; // 0 for beginning of the day
input int      EndHourTrade   = 23; // 23 for end of the day

extern string  data_10 = "==== Days to Trade ====";
input bool     January        = true;
input bool     February       = true;
input bool     March          = true;
input bool     April          = true;
input bool     May            = true;
input bool     June           = true;
input bool     July           = true;
input bool     August         = true;
input bool     September      = true;
input bool     October        = true;
input bool     November       = true;
input bool     December       = true;


//int CurrentTime;
int Slippage = 3;
int vSlippage;
int ticket;
int ticket_1,ticket_2,ticket_3;
int total_orders;
int count_1,count_2;
int current_spread;
int i,ii;
int RSIUpper,RSILower;
int StochUpper,StochLower;
   
double LotDigits = 2;
double trade_lots;
double vPoint; 
double turtle_S1_0,turtle_S1_1,turtle_S1_2;
double turtle_S2_0,turtle_S2_1,turtle_S2_2;
double turtle_SL_buy,turtle_SL_sell;
double ATR_med_0;
double SL_dist;
double SL,TP;

double stochastic_main_med_0,stochastic_main_med_1,stochastic_main_med_2;
double stochastic_signal_med_0,stochastic_signal_med_1,stochastic_signal_med_2;

bool IsLastOrderWin;
bool fake_order;

//+------------------------------------------------------------------+
//|  INIT FUNCTION                                                   |
//+------------------------------------------------------------------+

int OnInit()
   {
   
   //## Walk Forward Pro OnInit() code start (MQL4) ##
   //if(MQLInfoInteger(MQL_TESTER))
   //WFA_Initialise();
   //## Walk Forward Pro OnInit() code end (MQL4) ##
   
   //CurrentTime= Time[0];
   IsLastOrderWin=false;

//+------------------------------------------------------------------+
//|  Detect 3/5 digit brokers for Point and Slippage                 |
//+------------------------------------------------------------------+
   
   if(Point==0.00001)
      { vPoint=0.0001; vSlippage=Slippage *10;}
   else
      {
      if(Point==0.001)
        { vPoint=0.01; vSlippage=Slippage *10;}
      else vPoint=Point; vSlippage=Slippage;
      }
   
   StochUpper = 100 - Stoch_range;
   StochLower = Stoch_range;
   
   return(0);
   }

//+------------------------------------------------------------------+
//|  MAIN PROGRAM                                                    |
//+------------------------------------------------------------------+

void OnTick()
  {

   //## Walk Forward Pro OnTick() code start (MQL4) ##
   //if(MQLInfoInteger(MQL_TESTER))
   //WFA_UpdateValues();
   //## Walk Forward Pro OnTick() code end (MQL4) ##

//+------------------------------------------------------------------+
//| INITIAL DATA CHECKS                                              |
//+------------------------------------------------------------------+

   //if(Bars<100)
   //  {
   //   Print("bars less than 100");
   //   return;
   //  }

      //if(AccountFreeMargin()<(1000*Lots))
      //  {
      //   Print("We have no money. Free Margin = ",AccountFreeMargin());
      //   return;
      //  }
//+------------------------------------------------------------------+
//| TO BE DONE                                                       |
//+------------------------------------------------------------------+
   
// add filter: skip one trade if previous close trade is positive. At 50%:Found a solution by opening a 0.01 lots order and check if it is a win or a loss, this is just 50% solution
// add System 2. DONE
// pyramiding up to X times

//+------------------------------------------------------------------+
//| BUY / SELL OPERATIONS                                            |
//+------------------------------------------------------------------+
   
   total_orders=CountOrder_symbol_magic();
   if(total_orders==0) //initialize and delete old pending orders
      {
      closeall_stop();
      bool pyramid_1 = false;
      bool pyramid_2 = false;
      }
   current_spread = MarketInfo(Symbol(),MODE_SPREAD);
   //Print("Hello WORLD");
   if(total_orders<orders && NewBar()==true && DayToTrade()==true && HourToTrade()==true && MonthToTrade()==true && NoFridayEvening()==true && AllowOrders==true && TimeBetweenOrders()==true && current_spread<=spread)
   //if(total<orders && DayToTrade()==true && HourToTrade()==true && MonthToTrade()==true && AllowOrders==true)
   //if(total<orders && NewBar()==true)
   //if(total_orders<orders)
      {
      
      //stochastic_main_med_0 = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 0);
      //stochastic_main_med_1 = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 1);
      //stochastic_main_med_2 = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 2);
      //stochastic_signal_med_0 = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
      //stochastic_signal_med_1 = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, 1);
      //stochastic_signal_med_2 = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, 2);
      
      //stochastic_main_med_1_100 = iStochastic(Symbol(), MED_TF, 100, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 1);
      //stochastic_main_med_2_100 = iStochastic(Symbol(), MED_TF, 100, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 2);
      
      ATR_med_0 = iATR(Symbol(),MED_TF,ATR_period,0);
      
      turtle_S1_0 = iCustom(Symbol(),MED_TF,"TheTurtleTradingChannel",Trade_Period_S1,Stop_Period_S1,Strict,false,6,0);
      turtle_S1_1 = iCustom(Symbol(),MED_TF,"TheTurtleTradingChannel",Trade_Period_S1,Stop_Period_S1,Strict,false,6,1);
      turtle_S1_2 = iCustom(Symbol(),MED_TF,"TheTurtleTradingChannel",Trade_Period_S1,Stop_Period_S1,Strict,false,6,2);
      
      //turtle_S2_0 = iCustom(Symbol(),MED_TF,"TheTurtleTradingChannel",Trade_Period_S2,Stop_Period_S2,Strict,false,6,0);
      //turtle_S2_1 = iCustom(Symbol(),MED_TF,"TheTurtleTradingChannel",Trade_Period_S2,Stop_Period_S2,Strict,false,6,1);
      //turtle_S2_2 = iCustom(Symbol(),MED_TF,"TheTurtleTradingChannel",Trade_Period_S2,Stop_Period_S2,Strict,false,6,2);

      
      //IsLastOrderWin = Last_Order_Profit();
      //--- check for BUY position
      
      if(
      //(turtle_S1_0==OP_BUY && stochastic_main_med_1>stochastic_signal_med_1 && stochastic_main_med_2<stochastic_signal_med_2 && stochastic_main_med_0<StochLower)
      (turtle_S1_1==OP_BUY && turtle_S1_2==OP_SELL && S1==true)
      //|| (turtle_S2_1==OP_BUY && turtle_S2_2==OP_SELL && S2==true)
      //&& Last_Order_Profit()==false
      )
         {
         SL_dist = ATR_SL_factor*ATR_med_0;
         SL = Ask - SL_dist;

         //TP = RR * SL_dist + Ask;
         TP = 0;
         trade_lots = GetLots(SL);
         
         if(IsLastOrderWin==false)
            {
            //if previous trade was a loss, continue. If previous trade was a win, skip trade
            
            if(pyramidying == false)
               {
               ticket=OrderSend(Symbol(),OP_BUY,trade_lots,Ask,vSlippage,SL,TP,"Blackrain Trend Turtle",magic_number,0,Green);
                        
               if(ticket>0)
                  {
                  if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                     {
                     Print("BUY order opened at ",OrderOpenPrice());
                     }
                  }
               else
                  {
                  Print("Error opening BUY order : ",GetLastError());
                  }
               fake_order=false;   
               }
            }   
         else
            {
            //IsLastOrderWin=false;
            ticket=OrderSend(Symbol(),OP_BUY,0.01,Ask,vSlippage,SL,TP,"Blackrain Trend Turtle",magic_number,0,Green);
            fake_order=true;
            }      
         
         if(pyramidying == true)
            {
            ticket_1=OrderSend(Symbol(),OP_BUY,trade_lots,Ask,vSlippage,SL,Ask+(6*SL_dist),"Blackrain Trend Turtle",magic_number,0,Green);
            ticket_2=OrderSend(Symbol(),OP_BUYSTOP,trade_lots,NormalizeDouble(Ask+(2*SL_dist),5),vSlippage,Ask+(1*SL_dist),Ask+(6*SL_dist),"Blackrain Trend Turtle",magic_number,0,Green);
            ticket_3=OrderSend(Symbol(),OP_BUYSTOP,trade_lots,NormalizeDouble(Ask+(4*SL_dist),5),vSlippage,Ask+(3*SL_dist),Ask+(6*SL_dist),"Blackrain Trend Turtle",magic_number,0,Green);
            }
               
         }
      
      //--- check for SELL position
            
      if(
      //(turtle_S1_0==OP_SELL && stochastic_main_med_1<stochastic_signal_med_1 && stochastic_main_med_2>stochastic_signal_med_2 && stochastic_main_med_0>StochUpper)
      (turtle_S1_1==OP_SELL && turtle_S1_2==OP_BUY && S1==true)
      //|| (turtle_S2_1==OP_SELL && turtle_S2_2==OP_BUY && S2==true) 
      //&& Last_Order_Profit()==false
      )
         {
         SL_dist = ATR_SL_factor*ATR_med_0;
         SL = Bid + SL_dist;

         //TP = Bid - RR * SL_dist;
         TP = 0;
         trade_lots = GetLots(SL);
            
         if(IsLastOrderWin==false)
            {
            //if previous trade was a loss, continue. If previous trade was a win, skip trade
            
            if(pyramidying == false)
               {
               ticket=OrderSend(Symbol(),OP_SELL,trade_lots,Bid,vSlippage,SL,TP,"Blackrain Trend Turtle",magic_number,0,Red);
                        
               if(ticket>0)
                  {
                  if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                     {
                     Print("SELL order opened at ",OrderOpenPrice());
                     }
                  }
               else
                  {
                  Print("Error opening SELL order : ",GetLastError());
                  }
               fake_order=false;   
               }
            }
         else
            {
            //IsLastOrderWin=false;
            ticket=OrderSend(Symbol(),OP_SELL,0.01,Bid,vSlippage,SL,TP,"Blackrain Trend Turtle",magic_number,0,Red);
            fake_order=true;
            }      
         
         if(pyramidying == true)
            {
            ticket_1=OrderSend(Symbol(),OP_SELL,trade_lots,Bid,vSlippage,SL,Bid-(6*SL_dist),"Blackrain Trend Turtle",magic_number,0,Green);
            ticket_2=OrderSend(Symbol(),OP_SELLSTOP,trade_lots,NormalizeDouble(Bid-(2*SL_dist),5),vSlippage,Bid-(1*SL_dist),Bid-(6*SL_dist),"Blackrain Trend Turtle",magic_number,0,Green);
            ticket_3=OrderSend(Symbol(),OP_SELLSTOP,trade_lots,NormalizeDouble(Bid-(4*SL_dist),5),vSlippage,Bid-(3*SL_dist),Bid-(6*SL_dist),"Blackrain Trend Turtle",magic_number,0,Green);
            }
               
         }

      return;
      }


//+------------------------------------------------------------------+
//| PYRAMIDYING                                                      | IMPLEMENT THE STEP BY STEP PROCESS AND FOR BUY / SELL VARIANTS. CAN I DO IT WITH A LOOP TO REDUCE CODE OR BETTER EXTRA CODE AS IT IS JUST 2 POSITIONS?
//+------------------------------------------------------------------+   
  
//   if(pyramidying == true && CountOrder_symbol_magic()>max_pyramid_trades) // Put conditions to detect trend, e.g. count if EMA20 (EMA50, EMA100 or other) is rising, or if price is higher than several previous periods (Turtle)
//      {
         //USE APPROACH AS IN TS, AND USE LAST ORDER DATA
//      if(total_orders==2 && pyramid_1==false) //means that the second order is activated. What to do when 2nd order is activated->move SL to 1R (grab ticket_1 and change SL)
//         {
//         if(!OrderSelect(ticket_1,SELECT_BY_TICKET,MODE_TRADES)) return;
//            {
//            if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
//               {
//               double dist=OrderOpenPrice()-OrderStopLoss();
//               
//               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+1*dist,OrderTakeProfit(),0,Green))
//                  {
//                  Print("OrderModify error is due to pyramidying, error ",GetLastError());
//                  }
//               else
//                  {
//                  pyramid_1 = true;
//                  Print("PYRAMIDYING done for 1st and 2nd order");
//                  }
//               }
//            }      
//         }
//      if(total_orders==3 && pyramid_2==false) //what to do when 2nd order is activated->move SL to 3R
//         {
//         if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
//            {
//            double dist=OrderOpenPrice()-OrderStopLoss();
//            
//            if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+1*dist,OrderTakeProfit(),0,Green))
//               {
//               Print("OrderModify error is due to pyramidying, error ",GetLastError());
//               }
//            else
//               {
//               pyramid_1 = true;
//               Print("PYRAMIDYING done for 1st and 2nd order");
//               }
//            }
//         }       
//      }

//+------------------------------------------------------------------+
//| MANAGE OPEN ORDERS: TRAILING                                     |
//+------------------------------------------------------------------+   
   
   // Trailing stop   PARTIAL CLOSE WHEN PRICE MOVE TrailingStop VALUE
   if(trailing == true && CountOrder_symbol_magic()>0)
      {
      //TS_pips();
      TS_RRratio();
      }

//+------------------------------------------------------------------+
//| MANAGE OPEN ORDERS: BREAKEVEN AND CLOSING OF TRADES              |
//+------------------------------------------------------------------+ 

   if(total_orders>0)
      {
      for(int cnt=OrdersTotal()-1;cnt>=0;cnt--)
         {
         if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) continue;
            //Print("ERROR on OrderSelect, ticket: ",OrderTicket(),", Error: ",GetLastError());
            //continue;
            {
            if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number) //check for order types, symbol and magic number
               {
               if(management_trade==true)
                  {
                  
                  //turtle_SL_buy = iCustom(Symbol(),MED_TF,"TheTurtleTradingChannel",Trade_Period_S1,Stop_Period_S1,Strict,false,2,0);
                  //turtle_SL_sell = iCustom(Symbol(),MED_TF,"TheTurtleTradingChannel",Trade_Period_S1,Stop_Period_S1,Strict,false,3,0);
                  
                  turtle_S1_0 = iCustom(Symbol(),MED_TF,"TheTurtleTradingChannel",Trade_Period_S1,Stop_Period_S1,Strict,false,6,0);
                  turtle_S1_1 = iCustom(Symbol(),MED_TF,"TheTurtleTradingChannel",Trade_Period_S1,Stop_Period_S1,Strict,false,6,1);
                  
                  //if(breakeven==true &&
                  //((stochastic_main_med_0<stochastic_signal_med_0 && stochastic_main_med_1>stochastic_signal_med_1 && stochastic_main_med_0>stoch_inv_upper && OrderType()==OP_BUY && Bid>OrderOpenPrice()) 
                  //|| (stochastic_main_med_0>stochastic_signal_med_0 && stochastic_main_med_1<stochastic_signal_med_1 && stochastic_main_med_0<stoch_inv_lower && OrderType()==OP_SELL && Bid<OrderOpenPrice())
                  //))
                  //   {
                  //   BE();
                  //   }
                  
                     
                  // Close BUY trades, exit
                  if(close_trade == true &&
                  //(turtle_SL_buy>=Bid && OrderType()==OP_BUY
                  (turtle_S1_0==OP_SELL && turtle_S1_1==OP_BUY && OrderType()==OP_BUY
                  ))
                     {
                     closeall();
                     closeall_stop();
                     //if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrMagenta))
                     //Print("BUY order ERROR close due to invalidation of current setup: ",OrderTicket(),", Error: ",GetLastError());
                     //else
                     //Print("BUY order closed due to invalidation of current setup");
                     }
                  
                  // Close SELL trades, exit
                  if(close_trade == true &&
                  //(turtle_SL_sell<=Bid && OrderType()==OP_SELL
                  (turtle_S1_0==OP_BUY && turtle_S1_1==OP_SELL && OrderType()==OP_SELL
                  ))
                     {
                     closeall();
                     closeall_stop();
                     //if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrMagenta))
                     //Print("SELL order ERROR close due to invalidation of current setup: ",OrderTicket(),", Error: ",GetLastError());
                     //else
                     //Print("SELL order closed due to invalidation of current setup");
                     }
                  }   
                  
               // Close trades due to their duration
               if(CloseOnDuration==true)
                  {
                  int MaxDuration = (MaxDurationHours * 60 * 60) + (MaxDurationMin * 60); //transform hours to seconds
                  int Duration = TimeCurrent() - OrderOpenTime();

                  if(Duration>=MaxDuration) // add condition to be applied only is price is lower or higher than open price, check both situations!!
                     {
                     if(OrderType()==OP_BUY && Bid>OrderOpenPrice())
                        {
                        if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrMagenta))
                        Print("BUY order ERROR on close due to duration: ",OrderTicket(),", Error: ",GetLastError());
                        else
                        Print("BUY order closed due to duration of the trade");
                        }
                     if(OrderType()==OP_SELL && Ask<OrderOpenPrice())
                        {
                        if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrMagenta))
                        Print("SELL order ERROR on close due to duration: ",OrderTicket(),", Error: ",GetLastError());
                        else
                        Print("SELL order closed due to duration of the trade");
                        }   
                     }
                  }
               
               // Close trades on Fridays evening
               if(CloseFridays==true)
                  {
                  if(DayOfWeek()==5 && Hour()>=21 && Minute()>=59)
                     {
                     if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrMagenta))
                     Print("Order ERROR on close on Friday: ",OrderTicket(),", Error: ",GetLastError());
                     else
                     Print("Trade closed due to End Of The Week");
                     }
                  }
               
               //Use retrace function to give the price a bit more room to operate. If a limit is exceeded, TP is used as nearby SL. The hard-SL is set on SL parameter
               if(retrace==true)
                  {
                  if(OrderType()==OP_BUY && (OrderOpenPrice()-Bid)>vPoint*PipsStick && Bid<OrderOpenPrice() && OrderTakeProfit()>OrderOpenPrice())
                     {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderOpenPrice()-vPoint*PipsRetrace,0,Green))
                        Print("OrderModify error is due to RETRACE, error ",GetLastError());
                        else
                        Print("RETRACE done");
                     }
                  if(OrderType()==OP_SELL && (Ask-OrderOpenPrice())>vPoint*PipsStick && Ask>OrderOpenPrice() && OrderTakeProfit()<OrderOpenPrice())
                     {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderOpenPrice()+vPoint*PipsRetrace,0,Green))
                        //Print("OrderModify error ",GetLastError());
                        Print("OrderModify error is due to RETRACE, error ",GetLastError());
                        else
                        Print("RETRACE done");
                     }
                  }   
               }
            }
         }
      }
   }    


//double OnTester()
//   {
//   //## Walk Forward Pro OnTester() code start (MQL4)- When NOT calculating your own Custom Performance Criterion ##
//   double dCustomPerformanceCriterion = NULL;  //This means the default Walk Forward Pro Custom Perf Criterion will be used
//   WFA_PerformCalculations(dCustomPerformanceCriterion);
//
//   return(dCustomPerformanceCriterion);
//   //## Walk Forward Pro OnTester() code end (MQL5) - When NOT calculating your own Custom Performance Criterion ##
//   }

//+------------------------------------------------------------------+
//| MONEY MANAGEMENT                                                 |
//+------------------------------------------------------------------+

double GetLots(double SAR) // Calculate the lots using the right currency conversion
   {
   double minlot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
   double lots;
   double MaxLots = maxlots;
   int correction;
   
   if(MM)
      {

      double LotSize = 1;
      double dist_SL;
      double point = Point;
      if((Digits==3) || (Digits==5))
        {
         point*=10;
        }
      //string DepositCurrency=AccountInfoString(ACCOUNT_CURRENCY);  
      double PipValue=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
       
      //MessageBox("DEPOSIT CURRENCY"+ DepositCurrency ,"ToolBox");
      //MessageBox("VALUE OF ONE PIP (1 LOT)="+ PipValue ,"ToolBox");
      
      //Print("VALUE OF ONE PIP is ",PipValue);
      
      if(Digits==3) {correction = 100;}
      if(Digits==5) {correction = 10000;}
      
      dist_SL = MathAbs((Bid-SAR)*correction);

      lots = NormalizeDouble((AccountBalance() * Risk/100) / (dist_SL*PipValue) , LotDigits);
      Print("Calculated lots: ",lots);

      // correction for the limits
      if(lots<minlot) lots = minlot;
      if(lots>MaxLots) lots = MaxLots;
      if(MaxLots>maxlot) lots = maxlot;

      }
   else
      {
      if(lots<minlot) lots = minlot;
      if(lots>MaxLots) lots = MaxLots;
      if(MaxLots>maxlot) lots = maxlot;
      lots = NormalizeDouble(Lots,2);
      }   
   return(lots);   
   }


//+------------------------------------------------------------------+
//| CHECK NEW BAR BY OPEN TIME                                       |
//+------------------------------------------------------------------+
bool NewBar()
{
static datetime lastbar;
datetime curbar = Time[0];
if(lastbar!=curbar)
   {
   lastbar=curbar;
   return (true);
   }
   else
   {
   return(false);
   }
}


//+------------------------------------------------------------------+
//| BREAKEVEN                                                        |
//+------------------------------------------------------------------+
void BE()
   {
   int cnt;
   int ordertotal;
   
   ordertotal=OrdersTotal();
   
   for(cnt=ordertotal-1; cnt>=0; cnt--)
      {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
         {
         //if(Bid>OrderOpenPrice()+BreakevenStop*vPoint)
         if(Bid>OrderOpenPrice())
            {
            //if(OrderStopLoss()<=OrderOpenPrice())
            if(OrderStopLoss()<OrderOpenPrice())
               {
               //if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+BreakevenDelta*vPoint,OrderTakeProfit(),0,Green))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Green))
                  Print("OrderModify error ",GetLastError());
               return;
               }
            }
         }
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
         {
         //if(Ask<OrderOpenPrice()-BreakevenStop*vPoint)
         if(Ask<OrderOpenPrice())
            {
            //if(OrderStopLoss()>=OrderOpenPrice())
            if(OrderStopLoss()>OrderOpenPrice())
               {
               //if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-BreakevenDelta*vPoint,OrderTakeProfit(),0,Green))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Green))
                  Print("OrderModify error ",GetLastError());
               return;
               }
            }
         }   
      }
   }

//+------------------------------------------------------------------+
//| CHECK IF TIME OF PREVIOUS ORDER                                  |
//+------------------------------------------------------------------+
bool TimeBetweenOrders()
   {
   bool OpenOrder=true;

   if(ticket>0)
      {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY))
         {
         //if(((TimeCurrent()-OrderCloseTime())<=time_between_trades) && OrderSymbol()==Symbol()) //time in seconds
         if(((TimeCurrent()-OrderOpenTime())<=time_between_trades) && OrderSymbol()==Symbol()) //time in seconds
            {
            datetime a=TimeCurrent();
            datetime b=OrderCloseTime();
            Print("Can't open a new trade, too early");
            //Print(a);
            //Print(b);
            Print("Time between old order and new one ",a-b," seconds");
            OpenOrder=false;
            }
         }  
      }
   return(OpenOrder);
   }


//+------------------------------------------------------------------+
//| CLOSE ALL ORDERS                                                 |
//+------------------------------------------------------------------+
void closeall()
   {
   int cnt;
   int ordertotal;
   
   ordertotal = OrdersTotal();
   
   for(cnt=ordertotal-1; cnt>=0; cnt--)
      {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) continue;
      if((OrderType()==OP_BUY || OrderType()==OP_SELL) && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
         {
         if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,CLR_NONE))
         Print("Order Close failed at 'closeall': ",OrderTicket(), " Error: ",GetLastError());
         }
      }
   }

//+------------------------------------------------------------------+
//| CLOSE ALL STOP ORDERS                                            |
//+------------------------------------------------------------------+
void closeall_stop()
   {
   int cnt;
   int ordertotal;
   
   ordertotal = OrdersTotal();
   
   for(cnt=ordertotal-1; cnt>=0; cnt--)
      {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) continue;
      if((OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP) && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
         {
         if(!OrderDelete(OrderTicket(),CLR_NONE))
         Print("Order Close failed at 'closeall_stop': ",OrderTicket(), " Error: ",GetLastError());
         }
      }
   }

//+------------------------------------------------------------------+
//| CLOSE ALL BUY ORDERS                                             |
//+------------------------------------------------------------------+
void closeall_buy()
   {
   int cnt;
   int ordertotal;
   
   ordertotal = OrdersTotal();
   
   for(cnt=ordertotal-1; cnt>=0; cnt--)
      {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
         {
         if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,CLR_NONE))
         Print("Order Close failed at 'closeall_buy': ",OrderTicket(), " Error: ",GetLastError());
         }
      }
   }

//+------------------------------------------------------------------+
//| CLOSE ALL SELL ORDERS                                            |
//+------------------------------------------------------------------+
void closeall_sell()
   {
   int cnt;
   int ordertotal;
   
   ordertotal = OrdersTotal();
   
   for(cnt=ordertotal-1; cnt>=0; cnt--)
      {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
         {
         if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,CLR_NONE))
         Print("Order Close failed at 'closeall_sell': ",OrderTicket(), " Error: ",GetLastError());
         }
      }
   }
  
 
//+------------------------------------------------------------------+
//| COUNT OPEN ORDERS BY SYMBOL AND MAGIC NUMBER                     |
//+------------------------------------------------------------------+
int CountOrder_symbol_magic()
   {
   int cnt;
   int order_total;
   int ordertotal;
   
   order_total = 0;
   ordertotal = OrdersTotal();
   
   for(cnt=ordertotal-1; cnt>=0; cnt--)
      {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) continue;
      if((OrderType()==OP_BUY || OrderType()==OP_SELL) && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
         {
         order_total++;
         }
      }
   return (order_total);
   }

//+------------------------------------------------------------------+
//| COUNT BUY ORDERS BY SYMBOL AND MAGIC NUMBER                      |
//+------------------------------------------------------------------+
int CountBuyOrder_symbol_magic()
   {
   int cnt;
   int order_total;
   int ordertotal;
   
   order_total = 0;
   ordertotal = OrdersTotal();
   
   for(cnt=ordertotal-1; cnt>=0; cnt--)
      {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
         {
         order_total++;
         }
      }
   return (order_total);
   }

//+------------------------------------------------------------------+
//| COUNT SELL ORDERS BY SYMBOL AND MAGIC NUMBER                     |
//+------------------------------------------------------------------+
int CountSellOrder_symbol_magic()
   {
   int cnt;
   int order_total;
   int ordertotal;
   
   order_total = 0;
   ordertotal = OrdersTotal();
   
   for(cnt=ordertotal-1; cnt>=0; cnt--)
      {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
         {
         order_total++;
         }
      }
   return (order_total);
   }   

//+------------------------------------------------------------------+
//| LAST ORDER PROFIT OR LOSS                                        |
//+------------------------------------------------------------------+
bool Last_Order_Profit()
   {
   bool profit_order;
   int cnt;
   //int ticket = -1;
   int ticket_profit;
   datetime close_time = 0;
   for(cnt=OrdersHistoryTotal()-1; cnt>=0; cnt--)
   {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY)) continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber() == magic_number && OrderCloseTime() > close_time)
      {
      ticket_profit = OrderTicket();
      close_time = OrderCloseTime();
      if(OrderProfit()>0)
         {
         profit_order = true;
         }
      else
         {
         profit_order = false;
         }
      //Print("Order profit is ",profit_order);   
      }
   }

   return (profit_order);
   }


//+------------------------------------------------------------------+
//| TRAILING STOP BY PIPS                                            |
//+------------------------------------------------------------------+
void TS_pips()
   {
   int cnt;
   int ordertotal;
   //double TS;
   
   ordertotal=OrdersTotal();
   
   //if((TrailingStop)>=TakeProfit-5)
   //   {
   //   TS=TakeProfit-5;
   //   }
   //   else
   //   {
   //   TS=TrailingStop;
   //   }
   
   
   //Print("TS IS: ",TS);
   
   for(cnt=ordertotal-1; cnt>=0; cnt--)
      {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
         {
         if((Bid-OrderOpenPrice())>TrailingStop*vPoint)
         //if((Bid-OrderOpenPrice())>TS*vPoint)
            {
            if(OrderStopLoss()<(Bid-TrailingStop*vPoint))
            //if(OrderStopLoss()<(Bid-TS*vPoint))
               {
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop*vPoint,OrderTakeProfit(),0,Green))
               //if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TS*vPoint,OrderTakeProfit(),0,Green))
                  Print("OrderModify error is because TS, error ",GetLastError());
               return;
               }
            }
         }
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
         {
         if((OrderOpenPrice()-Ask)>TrailingStop*vPoint)
         //if((OrderOpenPrice()-Ask)>TS*vPoint)
            {
            if(OrderStopLoss()>(Ask+TrailingStop*vPoint))
            //if(OrderStopLoss()>(Ask+TS*vPoint))
               {
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStop*vPoint,OrderTakeProfit(),0,Green))
               //if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TS*vPoint,OrderTakeProfit(),0,Green))
                  Print("OrderModify error is because TS, error ",GetLastError());
               return;
               }
            }
         }   
      }
   }

//+------------------------------------------------------------------+
//| TRAILING STOP BY RISK-REWARD RATIO                               |
//+------------------------------------------------------------------+
void TS_RRratio()
   {
   int cnt;
   int ordertotal;
   //int shift_bar;
   
   double dist_open_to_initSL;
   
   ordertotal=OrdersTotal();
   
   for(cnt=ordertotal-1; cnt>=0; cnt--) //deberia funcionar en combinación con piramidar: no funciona pq una vez cumplidas las condiciones no las aplica a cada order abierta
      {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
         {
         //shift_bar = iBarShift(Symbol(),MED_TF,OrderOpenTime(),false);
         //dist_open_to_initSL = OrderOpenPrice()-MathMin(iSAR(Symbol(),MED_TF,SAR_step_med,SAR_max,shift_bar),iSAR(Symbol(),MED_TF,SAR_step_med,SAR_max,shift_bar+1));
         dist_open_to_initSL = MathAbs(OrderOpenPrice()-OrderStopLoss());
                  
         if((Bid-OrderOpenPrice())>TS_RRratio_step*dist_open_to_initSL) //solo funciona para la primera vez ya que compara con el precio de apertura, el parametro determina la distancia per el primer movimiento de SL
            {
            if(OrderStopLoss()<(Bid-(TS_RRratio_step+TS_RRratio_sl)*dist_open_to_initSL)) // creo que esta condicion es correcta, procede si el SL està a 3R de distancia del precio
               {
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TS_RRratio_sl*dist_open_to_initSL,OrderTakeProfit(),0,Green)) //esto tambien parece correcto, mueve el SL a 1R de distancia del precio actual
                  Print("OrderModify error is because TS, error ",GetLastError());
               return;
               }
            }
         }
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number)
         {
         //shift_bar = iBarShift(Symbol(),MED_TF,OrderOpenTime(),false);
         //dist_open_to_initSL = MathMax(iSAR(Symbol(),MED_TF,SAR_step_med,SAR_max,shift_bar),iSAR(Symbol(),MED_TF,SAR_step_med,SAR_max,shift_bar+1))-OrderOpenPrice();
         dist_open_to_initSL = MathAbs(OrderStopLoss()-OrderOpenPrice());
         
         if((OrderOpenPrice()-Ask)>TS_RRratio_step*dist_open_to_initSL)
            {
            if(OrderStopLoss()>(Ask+(TS_RRratio_step+TS_RRratio_sl)*dist_open_to_initSL))
               {
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TS_RRratio_sl*dist_open_to_initSL,OrderTakeProfit(),0,Green))
                  Print("OrderModify error is because TS, error ",GetLastError());
               return;
               }
            }
         }   
      }
   }

////+------------------------------------------------------------------+
////| NEWS TIME FUNCTION                                               |
////+------------------------------------------------------------------+
// bool NewsHandling()
//   {
//    //static int PrevMinute = -1;
//    //   if (Minute() != PrevMinute)
//    //     {
//    //     PrevMinute = Minute();
//         //int minutesSincePrevEvent = iCustom(NULL, 0, "FFCal", true, true, false, true, true, 1, 0);
//         //int minutesUntilNextEvent = iCustom(NULL, 0, "FFCal", true, true, false, true, true, 1, 1);
//        
//         //int minutesSincePrevEvent = iCustom(NULL, 0, "FFCal", IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, 1, DSTOffsetHours, 1, 0);
//         //int minutesUntilNextEvent = iCustom(NULL, 0, "FFCal", IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, 1, DSTOffsetHours, 1, 1);
//        
//   int minutesAfterPrevEvent = iCustom(NULL, 0, "FFC", true, IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, IncludeHolidays,"","", true, 4, 0, 1);
//   int minutesBeforeNextEvent = iCustom(NULL, 0, "FFC", true, IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, IncludeHolidays,"","", true, 4, 0, 0);
//      
//   data_news =
//   "\n                              Minutes Before next News Event = " + minutesBeforeNextEvent
//   +"\n                              Minutes After previous News Event = " + minutesAfterPrevEvent;
//      
//   if (minutesBeforeNextEvent <= MinsBeforeNews || minutesAfterPrevEvent <= MinsAfterNews)
//      {
//      NewsTime = true;
//      }
//      else
//      {
//      NewsTime = false;
//      }
//    return(NewsTime);
//    }

/*
FFC Advanced call:
-------------
iCustom(
        string       NULL,            // symbol 
        int          0,               // timeframe 
        string       "FFC",           // path/name of the custom indicator compiled program 
        bool         true,            // true/false: Active chart only 
        bool         true,            // true/false: Include High impact
        bool         true,            // true/false: Include Medium impact
        bool         true,            // true/false: Include Low impact
        bool         true,            // true/false: Include Speaks
        bool         false,           // true/false: Include Holidays
        string       "",              // Find keyword
        string       "",              // Ignore keyword
        bool         true,            // true/false: Allow Updates
        int          4,               // Update every (in hours)
        int          0,               // Buffers: (0) Minutes, (1) Impact
        int          0                // shift 
*/   
//   minutesSincePrevEvent = iCustom(NULL, 0, "FFC", true, IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, IncludeHolidays,"","", true, 4, 0, 0);
//
//   minutesUntilNextEvent = iCustom(NULL, 0, "FFC", true, IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, IncludeHolidays,"","", true, 4, 0, 1);
//
//   impactOfPrevEvent = iCustom(NULL, 0, "FFC", true, IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, IncludeHolidays,"","", true, 4, 1, 0);
//
//   impactOfNextEvent = iCustom(NULL, 0, "FFC", true, IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, IncludeHolidays,"","", true, 4, 1, 1);

// FFCAL call

//   minutesSincePrevEvent = iCustom(NULL, 0, "FFCal", true, true, false, true, true, 1, 0);
//
//   minutesUntilNextEvent = iCustom(NULL, 0, "FFCalendar", true, true, false, true, true, 1, 1);
//
//   impactOfPrevEvent = iCustom(NULL, 0, "FFCalendar", true, true, false, true, true, 2, 0);
//
//   impactOfNextEvent = iCustom(NULL, 0, "FFCalendar", true, true, false, true, true, 2, 1);

//+------------------------------------------------------------------+
//| DAYS TO AVOID TRADING                                            |
//+------------------------------------------------------------------+

bool DayToTrade()
   {
   bool daytotrade = false;
   
   //add here the conditions for days to avoid trading, choose FALSE or TRUE
   if(DayOfWeek() == 0) daytotrade = Sunday;
   if(DayOfWeek() == 1) daytotrade = Monday;
   if(DayOfWeek() == 2) daytotrade = Tuesday;
   if(DayOfWeek() == 3) daytotrade = Wednesday;
   if(DayOfWeek() == 4) daytotrade = Thursday;
   if(DayOfWeek() == 5) daytotrade = Friday;
   
   for(int jan=1;jan<=15;jan++)
      {
      if(DayOfYear()==jan) daytotrade = false;
      }
   
   for(int dec=350;dec<=365;dec++)
      {
      if(DayOfYear()==dec) daytotrade = false;
      }
   
   return(daytotrade);
   }

//+------------------------------------------------------------------+
//| HOURS TO AVOID TRADING                                           |
//+------------------------------------------------------------------+

bool HourToTrade()
   {
   bool hourtotrade = false;
   
   //add here the conditions for hours to avoid trading, choose FALSE or TRUE

   if(Hour()>=StartHourTrade && Hour()<=EndHourTrade) hourtotrade = true; 
   
   return(hourtotrade);
   }
   
//+------------------------------------------------------------------+
//| MONTH TO AVOID TRADING                                           |
//+------------------------------------------------------------------+

bool MonthToTrade()
   {
   bool monthtotrade = false;
   
   //add here the conditions for month to avoid trading, choose FALSE or TRUE

   if(Month() == 1) monthtotrade = January;
   if(Month() == 2) monthtotrade = February;
   if(Month() == 3) monthtotrade = March;
   if(Month() == 4) monthtotrade = April;
   if(Month() == 5) monthtotrade = May;
   if(Month() == 6) monthtotrade = June;
   if(Month() == 7) monthtotrade = July;
   if(Month() == 8) monthtotrade = August;
   if(Month() == 9) monthtotrade = September;
   if(Month() == 10) monthtotrade = October;
   if(Month() == 11) monthtotrade = November;
   if(Month() == 12) monthtotrade = December;                       
   
   return(monthtotrade);
   }

//+------------------------------------------------------------------+
//| TRADE ON FRIDAY EVENING                                          |
//+------------------------------------------------------------------+
   
bool NoFridayEvening()
   {
   bool fridayevening = true;
   
   if(DayOfWeek() == 5 && Hour()>=22) fridayevening = false;
   
   return(fridayevening);
   }
   
//+------------------------------------------------------------------+
