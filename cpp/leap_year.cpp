// Author:  Audel Rouhi
// Date:   03/05/2024
// Purpose: CS116-PJ1: Check whether the year (entered by the user) is a leap year or not.
#include <iostream>	   // Access input/output stream: cin cout
using namespace std;    // Access cout, endl, cin without using std:: as prefix
bool IsLeapYear(int year); // Prototype for this boolean function to be defined later after main
int main() // main program starts here: C++ execution starts here: // must return integer
{ // begin main()
	int n = 1; // line number for separator line ================ // integer n gets one.
	           // to make the output look really nice and organized
	cout << "Welcome to the Leap Year Check Tool of Audel Rouhi!" << endl; // output
                                                       // <-- must use your name
	int the_year;	  // the year to be checked is an integer
	while (true)   // Forever loop until break is hit inside the loop
	{ // begin while (true) loop
		cout << n++ << "=======================================================." << endl;
		cout << "Please enter a year AD (for example: 1997, -100 to exit): "
			<< endl;  	// Prompt for input from user
		cin >> the_year;   	// Read year as input from user
		if (the_year == -100) break; // exit the loop if year is -100
		if (IsLeapYear(the_year))    // call function to check whether it is a leap year
			cout << the_year << " is a leap year." << endl;
		else // NOT a leap year
			cout << the_year << " is NOT a leap year." << endl;
	} // end while (true) loop
	cout << n++ << "=======================================================." << endl;
	cout << "Thank you for using the Leap Year Check Tool of Audel Rouhi!" << endl; //output
                                                                  // <-- must use your name
	cout << n++ << "=======================================================." << endl << endl;
	cout << "Press Ctrl+Alt+PrntScrn to copy console, then enter a number to exit" << endl;
	cin >> n; // get a number n from user and exit
	return 0; // return 0 to the caller to indicate the successful completion of main()
} // end main ( )
//======================================================================================.
// The following is to define function IsLeapYear( )
// Input argument: int year
// Return to the caller: true or false (to show whether the year is a leap year or not)
bool IsLeapYear(int year) // check year is a leap year or not // Boolean function
// IsLeapYear function returns true if year is a leap year and
//                     returns false otherwise.
{ // begin IsLeapYear( ) function
	if (year % 4 != 0)        // Is year NOT divisible by 4?
		return false;         // If so, it is NOT a leap year
	else if (year % 100 != 0) // Is year NOT a multiple of 100?
		return true;        // If so, it is a leap year
	else if (year % 400 != 0) // Is year NOT a multiple of 400?
		return false;	     // If so, it is NOT a leap year
	else           // otherwise it is a leap year.
		return true;    // Is a leap year indeed
} // end IsLeapYear( ) function
// end of C++ program ===================================================================.