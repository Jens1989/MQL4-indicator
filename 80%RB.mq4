//+------------------------------------------------------------------+
//|                                                     midrange.mq4 |
//|                                                             Jens |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Jens"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window       // Indicator is drawn in the main window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

const string NO_BAR_TEXT = "No candle selected. Hover over a candle to see the value.";

int OnInit()
{
    ObjectCreate("Midrange", OBJ_LABEL, 0, 0, 0);
    ObjectSet("Midrange", OBJPROP_CORNER, 1);
    ObjectSet("Midrange", OBJPROP_XDISTANCE, 10);
    ObjectSet("Midrange", OBJPROP_YDISTANCE, 15);
    
    ObjectCreate("0.2 ATR", OBJ_LABEL, 0, 0, 0);
    ObjectSet("0.2 ATR", OBJPROP_CORNER, 1);
    ObjectSet("0.2 ATR", OBJPROP_XDISTANCE, 10);
    ObjectSet("0.2 ATR", OBJPROP_YDISTANCE, 30);
    
    ObjectCreate("0.6 ATR", OBJ_LABEL, 0, 0, 0);
    ObjectSet("0.6 ATR", OBJPROP_CORNER, 1);
    ObjectSet("0.6 ATR", OBJPROP_XDISTANCE, 10);
    ObjectSet("0.6 ATR", OBJPROP_YDISTANCE, 45);
    
    ObjectCreate("close difference", OBJ_LABEL, 0, 0, 0);
    ObjectSet("close difference", OBJPROP_CORNER, 1);
    ObjectSet("close difference", OBJPROP_XDISTANCE, 10);
    ObjectSet("close difference", OBJPROP_YDISTANCE, 60);

    ObjectCreate("2x stretch", OBJ_LABEL, 0, 0, 0);
    ObjectSet("2x stretch", OBJPROP_CORNER, 1);
    ObjectSet("2x stretch", OBJPROP_XDISTANCE, 10);
    ObjectSet("2x stretch", OBJPROP_YDISTANCE, 75);
    
    ObjectCreate("2.5x stretch", OBJ_LABEL, 0, 0, 0);
    ObjectSet("2.5x stretch", OBJPROP_CORNER, 1);
    ObjectSet("2.5x stretch", OBJPROP_XDISTANCE, 10);
    ObjectSet("2.5x stretch", OBJPROP_YDISTANCE, 90);
    
    ObjectCreate("3.5x stretch", OBJ_LABEL, 0, 0, 0);
    ObjectSet("3.5x stretch", OBJPROP_CORNER, 1);
    ObjectSet("3.5x stretch", OBJPROP_XDISTANCE, 10);
    ObjectSet("3.5x stretch", OBJPROP_YDISTANCE, 105);        
    SetNoBarSelected();
    
    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
    
    return(INIT_SUCCEEDED);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
     if (id == CHARTEVENT_MOUSE_MOVE) {
     
        // Find the bar index first
        datetime dateTime = 0;
        double price = 0;
        int window = 0;
        ChartXYToTimePrice(0, (int)lparam, (int)dparam, window, dateTime, price);
        int barIndex = iBarShift(NULL, 0, dateTime, true);
        
        // If the index is -1, no valid bar is selected
        if (barIndex == -1) {
            SetNoBarSelected();
            return;
        }
        
        // Now, find the coordinates for the high and low of that bar
        int lowX, lowY, highX, highY = 0;
        ChartTimePriceToXY(0, window, dateTime, High[barIndex], lowX, lowY);
        ChartTimePriceToXY(0, window, dateTime, Low[barIndex], highX, highY);
        
        // If the mouse pointer is above the candle high or below the candle low, don't show anything
        if ((int)dparam < lowY || dparam > highY) {
            SetNoBarSelected();
            return;
        }
        
        // Finally, show our bar info
        ShowBarInfo(barIndex);
     }
}

// Given a bar index, show some data about that bar
void ShowBarInfo(int index)
{   
    double midrange_value;
    double point_two_ATR;
    double point_six_ATR;
    double close_difference;
    double stretchx2;         // the average value of the 10 period stretch 
    double stretchx25;        // 2.5 times the stretch
    double stretchx35;        // 3.5 times the stretch

    
    midrange_value = (Close[index]-Low[index])/(High[index]-Low[index]);
    
    point_two_ATR = iATR(NULL,0,3,index)*0.2*100;
    
    point_six_ATR = iATR(NULL,0,3,index)*0.6*100;
    
    close_difference = (Close[index] - Close[index+1])*100;
    
    stretchx2 = Stretch(index)*2;
    stretchx25 = Stretch(index)*2.5; 
    stretchx35 = Stretch(index)*3.5;
       
      //int range = (int)MathRound((High[index] - Low[index]) / Point / 10);
      //ObjectSetText("Label_High", "Candle high: " + DoubleToString(High[index]), 10, "Arial", clrYellow);
      //ObjectSetText("Label_Low", "Candle low: " + DoubleToString(Low[index]), 10, "Arial", clrYellow);
      ObjectSetText("Midrange", "Midrange: " + DoubleToString(midrange_value,2), 10, "Arial", clrYellow);
      ObjectSetText("0.2 ATR", "0.2 ATR: " + DoubleToString(point_two_ATR,0), 10, "Arial", clrYellow);
      ObjectSetText("0.6 ATR", "0.6 ATR: " + DoubleToString(point_six_ATR,0), 10, "Arial", clrYellow);
      ObjectSetText("close difference", "C - PC: " + DoubleToString(close_difference,0), 10, "Arial", clrYellow);
      ObjectSetText("2x stretch", "2x stretch: " + DoubleToString(stretchx2,0), 10, "Arial", clrYellow);
      ObjectSetText("2.5x stretch", "2.5x stretch: " + DoubleToString(stretchx25,0), 10, "Arial", clrYellow);
      ObjectSetText("3.5x stretch", "3.5x stretch: " + DoubleToString(stretchx35,0), 10, "Arial", clrYellow);
}

// Show a message that no bar is selected
void SetNoBarSelected()
{
    ObjectSetText("Label_High", NO_BAR_TEXT, 10, "Arial", clrYellow);
    ObjectSetText("Label_Low", "", 10, "Arial", clrYellow);
    ObjectSetText("Midrange", "", 10, "Arial", clrYellow);
    ObjectSetText("0.2 ATR", "", 10, "Arial", clrYellow);
    ObjectSetText("0.6 ATR", "", 10, "Arial", clrYellow);
    ObjectSetText("C - (PC-1)", "", 10, "Arial", clrYellow);
    ObjectSetText("2x stretch", "", 10, "Arial", clrYellow);
    ObjectSetText("2.5x stretch", "", 10, "Arial", clrYellow);
    ObjectSetText("3.5x stretch", "", 10, "Arial", clrYellow);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[],
                const double &high[], const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
   return(rates_total);
}

double Stretch(int index)
    {
    double stretch;
    double openVhigh;           // calculate the difference between the open and the high to find the stretch
    double openVlow;            // calculate the difference between the open and the low to find the stretch
    double total;
    
    total = 0.0;
    
    for(int x = index; x<(index+10); x++)
       {
    openVhigh = High[x] - Open[x];
    openVlow = Open[x] - Low[x];
      
    if (openVhigh <= openVlow)
         {
       total += openVhigh;
         }
    else
         {
       total += openVlow;
         }
       }
    stretch = total/10;
    
    return  stretch;
    }
    

int deinit()
   {
   
   ObjectDelete("Midrange");
   ObjectDelete("Label_Low");
   ObjectDelete("Label_Range");
   ObjectDelete("0.2 ATR");
   ObjectDelete("0.6 ATR");
   ObjectDelete("close difference");
   
   
   return(0);
   
   }