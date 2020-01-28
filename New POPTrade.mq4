//+------------------------------------------------------------------+
//|                                                 New POPTrade.mq4 |
//|                                 Copyright 2019, Rindaman DukeAce |
//|                                          https://www.dukeace.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Rindaman DukeAce"
#property link      "https://www.dukeace.com"
#property version   "1.00"

int CrossCnt=0;
string symbol=Symbol();

int SellsOpen, BuysOpen;
double SellsOpenProfit, BuysOpenProfit;
bool UseTradingHours = true;
input int TP=50;
extern int OpenHour = 08;
extern int OpenMin = 30;
extern int CloseHour = 17;
extern int CloseMin = 30;
extern bool Trade_Friday = FALSE;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int LastBars;
string Allow;
void OnTick()
  {
//---
//TRStop(TR);
   if(TradingHours() == true)
      Allow="Yes";
   else
      Allow="No";
   double DD=NormalizeDouble(((1-AccountEquity()/AccountBalance())*100),2);
   double Loss=0;
   if(Loss>NormalizeDouble(AccountEquity()-AccountBalance(),2))
     {
      Loss=NormalizeDouble(AccountEquity()-AccountBalance(),2);
     }
   if(DayOfWeek()==5)
     {
      CloseBuyOrder();
      CloseSellOrder();
     }
//Print(TradingHours());
   OrdersTotalInfo();
   Comment("Buys Open : "+BuysOpen+
           "\nBuys Open Profit : "+BuysOpenProfit+
           "\nSells Open : "+SellsOpen+
           "\nSells Open Profit : "+SellsOpenProfit+
           "\nAccount Profits : "+AccountProfit()+
           "\nDay Of Week :"+DayOfWeek()+
           "\nCuttent %DD : "+DoubleToStr((1-AccountEquity()/AccountBalance())*100,2)+
           "\nCurrent Loss : "+Loss+
           "\nCrossCnt : "+CrossCnt+
           "\nAllow Trade : ");
   if(LastBars!=Bars)
     {
      if(RSI(60,0)>50&&Sto()>50)
        {
         Buy();
        }
      if(RSI(60,0)<50&&Sto()<50)
        {
         Sell();
        }
      if(OrdersTotal()>0)
        {
         ExitBuyOut();
         ExitSellOut();
         ExitSellIn();
         ExitBuyIn();
         if(CrossCnt>=2)
           {
            CloseBuyOrder();
            CrossCnt=0;
           }
         if(CrossCnt>=2)
           {
            CloseSellOrder();
            CrossCnt=0;
           }

        }

      OrdersTotalInfo();
      LastBars=Bars;
      /*   if(((DiSto(0,0)&&DiSto(1,0))<(70)
             &&((DiSto(0,1)>DiSto(1,1)&&DiSto(0,0)<DiSto(1,0))||(DiSto(0,1)<DiSto(1,1)&&DiSto(0,0)>DiSto(1,0)))
            )||((DiSto(0,0)&&DiSto(1,0))>(30)
                &&((DiSto(0,1)<DiSto(1,1)&&DiSto(0,0)>DiSto(1,0))||(DiSto(0,1)>DiSto(1,1)&&DiSto(0,0)<DiSto(1,0)))
               ))
           {
            counting();
            Print(CrossCnt);
           }

         else
            if(CrossCnt>=2)
              {
               CrossCnt=0;
              }*/
     }
  }
//+------------------------------------------------------------------+
double DMAC(int mode,int shift)
  {
   return iCustom(Symbol(),PERIOD_CURRENT,"Dinapoli MACD",mode,shift);
  }
double ADX(int mode,int shift)
  {
   return iADX(Symbol(),PERIOD_CURRENT,14,PRICE_CLOSE,mode,shift);
  }
int DiSto(int mode,int shift)
  {
   return iCustom(Symbol(),PERIOD_CURRENT,"Dinapoli Preferred Stochastic",8,3,3,mode,shift);
  }
//+------------------------------------------------------------------+

int ticket;
void Entry(int order_type)
  {
   double price=0;
   double takeprofit=0;
   if(order_type==OP_BUY)
     {
      price=Ask;
      takeprofit=NormalizeDouble(price+TP*Point,Digits);
      ticket = OrderSend(Symbol(),OP_BUY,0.01,price,3,0,takeprofit,NULL,1111);
     }
   if(order_type==OP_SELL)
     {
      price=Bid;
      takeprofit=NormalizeDouble(price-TP*Point,Digits);
      ticket = OrderSend(Symbol(),OP_SELL,0.01,price,3,0,takeprofit,NULL,2222);
     }
//ticket = OrderSend(Symbol(),order_type,0.01,price,0,0,0,);
   if(ticket<0)
      Print("OrderSend Error #",GetLastError());
  }
//+------------------------------------------------------------------+
void Buy()
  {
   if((DMAC(0,1)<DMAC(1,1))
      &&(DMAC(0,0)>DMAC(1,0))
      &&(ADX(1,0)>ADX(2,0))
      &&(ADX(1,0)-ADX(2,0))>=5
      &&(DMAC(0,1)<=(-0)))
     {
      Entry(OP_SELL);
     }
  }
//+------------------------------------------------------------------+
void Sell()
  {
   if((DMAC(0,1)>DMAC(1,1))
      &&(DMAC(0,0)<DMAC(1,0))
      &&(ADX(2,0)>ADX(1,0))
      &&(ADX(2,0)-ADX(1,0))>=5
      &&(DMAC(1,1)>0))
     {
      Entry(OP_BUY);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExitBuyOut()
  {
   if((DiSto(0,0)
       &&DiSto(1,0))>(70)
      &&DiSto(0,1)>DiSto(1,1)
      &&DiSto(0,0)<DiSto(1,0))//OverB Out Area
     {
      CloseSellOrder();
     }
   /*if((DiSto(0,0)&&DiSto(1,0))<(30)&&DiSto(0,1)<DiSto(1,1)&&DiSto(0,0)>DiSto(1,0))//OverS Out Area
     {
      CloseBuyOrder();
     }*/
//Print("Close Buy 2nd Cross");
//Comment("Close Buy 2nd Cross");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExitBuyIn()
  {
   if(((DiSto(0,0)
        &&DiSto(1,0))<(70)||(DiSto(0,0)
                             &&DiSto(1,0))>(30))
      &&ADX(2,0)<ADX(1,0))//&&CrossCnt==2
     {
      if(DiSto(0,1)>DiSto(1,1)
         &&DiSto(0,0)<DiSto(1,0))
        {
         counting();
         Print("Closs Buy In Area");
        }
     }
  }
void ExitSellOut()
  {
   /* if((DiSto(0,0)&&DiSto(1,0))>(70)&&DiSto(0,1)>DiSto(1,1)&&DiSto(0,0)<DiSto(1,0))//OverB Out Area
      {
       CloseSellOrder();
      }*/
   if((DiSto(0,0)
       &&DiSto(1,0))<(30)
      &&DiSto(0,1)<DiSto(1,1)
      &&DiSto(0,0)>DiSto(1,0))//OverS Out Area
     {
      CloseBuyOrder();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExitSellIn()
  {
   if(((DiSto(0,0)
        &&DiSto(1,0))<(70)||(DiSto(0,0)
                             &&DiSto(1,0))>(30))
      &&ADX(2,0)>ADX(1,0))//&&CrossCnt==2
     {
      if(DiSto(0,1)<DiSto(1,1)
         &&DiSto(0,0)>DiSto(1,0))
        {
         counting();
         Print("Closs Sell In Area");
        }

      //Print("Close Sell 2nd Cross");
      // Comment("Close Sell 2nd Cross");
     }
  }
//+------------------------------------------------------------------+
void CloseBuyOrder()
  {
   int total = OrdersTotal();
   for(int i=total-1; i>=0; i--)
     {
      OrderSelect(i, SELECT_BY_POS);
      int type   = OrderType();
      bool result = false;

      switch(type)
        {
         //Close opened long positions
         case OP_BUY       :
            result = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
            break;
         //Close pending orders
         case OP_BUYLIMIT  :
         case OP_BUYSTOP   :
            result = OrderDelete(OrderTicket());
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSellOrder()
  {
   int total = OrdersTotal();
   for(int i=total-1; i>=0; i--)
     {
      OrderSelect(i, SELECT_BY_POS);
      int type   = OrderType();
      bool result = false;

      switch(type)
        {
         //Close opened short positions
         case OP_SELL      :
            result = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
            break;
         //Close pending orders
         case OP_SELLLIMIT :
         case OP_SELLSTOP  :
            result = OrderDelete(OrderTicket());
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void counting()
  {
   CrossCnt++;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrdersTotalInfo()
  {
   SellsOpen=0;
   BuysOpen=0;
   BuysOpenProfit=0;
   SellsOpenProfit=0;
   for(int OrdersOpenTotal=OrdersTotal()-1; OrdersOpenTotal>=0; OrdersOpenTotal--)
     {
      if(OrderSelect(OrdersOpenTotal,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderSymbol()==symbol && OrderMagicNumber()==2222 &&
            //OrderComment()==_comment &&
            OrderType()==OP_SELL)
           {
            SellsOpen++;
            if(OrderProfit()>0)
              {
               SellsOpenProfit+=OrderProfit();
              }
           }
         else
           {
            if(OrderSymbol()==symbol  && OrderMagicNumber()==1111 &&
               //OrderComment()==_comment &&
               OrderType()==OP_BUY)
              {
               BuysOpen++;
               if(OrderProfit()>0)
                 {
                  BuysOpenProfit+=OrderProfit();
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TradingHours()
  {
   if(CloseHour>OpenHour) //within the day
     {
      if(OpenHour < TimeHour(TimeCurrent()) && TimeHour(TimeCurrent()) < CloseHour)
        {
         // Comment("Open For Trading");
         return(true);
        }
      if(OpenHour == TimeHour(TimeCurrent()))
        {
         if(OpenMin<=TimeMinute(TimeCurrent()))
           {
            // Comment("Open For Trading");
            return(true);
           }
         return(false);
        }

      if(CloseHour == TimeHour(TimeCurrent()))
        {
         if(CloseMin>=TimeMinute(TimeCurrent()))
           {
            //  Comment("Open For Trading");
            return(true);
           }
         return(false);
        }
      //Comment("Closed");
      return(false);
     }
   if(OpenHour>CloseHour)  //Spanning two days
     {
      if(CloseHour < TimeHour(TimeCurrent()) && TimeHour(TimeCurrent()) < OpenHour)
        {
         // Comment("Closed");
         return(false);
        }
      if(OpenHour == TimeHour(TimeCurrent()))
        {
         if(OpenMin<=TimeMinute(TimeCurrent()))
           {
            //  Comment("Open For Trading");
            return(true);
           }
         return(false);
        }
      if(CloseHour == TimeHour(TimeCurrent()))
        {
         if(CloseMin>=TimeMinute(TimeCurrent()))
           {
            //  Comment("Open For Trading");
            return(true);
           }
         return(false);
        }
      // Comment("Open For Trading");
      return(true);
     }
  }
//+------------------------------------------------------------------+


//-----------Time and Friday check--------------------


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
double RSI(int mode,int shift)
{
   return iRSI(Symbol(),PERIOD_CURRENT,mode,PRICE_CLOSE,shift);
}
//+------------------------------------------------------------------+
double Sto()
{
   return iStochastic(Symbol(),PERIOD_CURRENT,60,60,3,MODE_SMA,PRICE_CLOSE,0,0);
}