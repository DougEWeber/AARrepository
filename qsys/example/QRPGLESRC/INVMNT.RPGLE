      //****************************************************************
      // PROGRAM NAME:   INVMNT                                        *
      // RELATED FILES:  INVMSTL1 (LF)                                 *
      //                 INVMENU  (DSPF)                                *
      // DESCRIPTION:    This program shows an inventory master         *
      //                 maintenance program using a workstn file.     *
      //                 This program allows the user to add, display  *
      //                 and delete inventory records.                 *
      //                 PF3 is used to quit the program.               *
      //****************************************************************

     Finvmstl1  uf a e           k disk
     Finvmenu   cf   e             workstn indds(indicators)

      // Field definitions:

     D indicators      ds
     D   exitKey                       n   overlay(indicators:3)
     D   addKey                        n   overlay(indicators:5)
     D   deleteKey                     n   overlay(indicators:7)
     D   displayKey                    n   overlay(indicators:8)
     D   prevKey                       n   overlay(indicators:12)
     D   itemExists                    n   overlay(indicators:51)
     D   itemNotFound                  n   overlay(indicators:52)

      // Key list definitions:

     C     ITMKEY        KLIST
     C                   KFLD                    ITEMID
           //*****************************************************************
      //       MAINLINE                                                 *
      //*****************************************************************

      /free

       mode = 'DISPLAY';
       exfmt hdrscn;

       // Loop until exit key is pressed
       dow not exitKey;
          exsr SetMaintenanceMode;

          if itemid <> *blanks;
             if mode = 'ADD';
                exsr AddSub;
             elseif mode = 'DELETE';
                exsr DeleteSub;
             elseif mode = 'DISPLAY';
                exsr InquirySub;
             endif;
          endif;

          exfmt hdrscn;
          itemExists   = *off;   // turn off error messages
          itemNotFound = *off;
       enddo;

       *inlr = *on;
       //****************************************************************
       //    SUBROUTINE - AddSub                                        *
       //    PURPOSE    - Add new inventory item to file                *
       //****************************************************************
       begsr AddSub;

          // Is item ID already in file?
          chain ItmKey imlrec1;
          if %found(invmstl1);
             // Item ID is already being used
             itemExists = *on;
             leavesr;
          endif;

          // Initialize new item data
          itemExists   = *off;   // turn off error messages
          itemNotFound = *off;
          desc = *blank;
          qtyoh = 0;

          // Prompt for data for this item
          exfmt invbld;

          // If OK, add item to the inventory file
          if not *in12;
             write imlrec1;
          endif;
       endsr;  // end of subroutine AddSub



       //****************************************************************
       //    SUBROUTINE - DeleteSub                                     *
       //    PURPOSE    - Delete inventory master record                *
       //****************************************************************
       begsr DeleteSub;

          // Lookup item ID
          chain itmkey imlrec1;
          if not %found(invmstl1);
             // Item is not found in file
             itemNotFound = *on;
             leavesr;
          endif;

          // Display information for this item
          exfmt invinq;
          if not prevKey;
             // Delete inventory record
             delete imlrec1;
          else;
             // If we don't want to delete, at least unlock
             // the record.
             unlock invmstl1;
          endif;
       endsr;  // end of subroutine DeleteSub



       //****************************************************************
       //    SUBROUTINE - InquirySub                                    *
       //    PURPOSE    - Display inventory master record               *
       //****************************************************************
       begsr InquirySub;

          // Lookup item ID
          chain(n) itmkey imlrec1;  // don't lock record
          if not %found(invmstl1);
             // Item is not found in file
             itemNotFound = *on;
             leavesr;
          endif;

          // Display information for this item
          exfmt invinq;
       endsr;  // end of subroutine InquirySub;
       //****************************************************************
       //    SUBROUTINE - SetMaintenanceMode                            *
       //    PURPOSE    - Set maintenance mode                          *
       //****************************************************************
       begsr SetMaintenanceMode;
          if addKey;
             mode = 'ADD';
          elseif deleteKey;
             mode = 'DELETE';
          elseif displayKey;
             mode = 'DISPLAY';
          endif;
       endsr;  // end of subroutine SetMaintenanceMode

      /end-free

