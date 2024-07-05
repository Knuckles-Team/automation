#include <iostream>
#include <iomanip>
using namespace std;

double loan_amount = 50000.00;
int number_of_years = 5;
double yearly_percent_int;
double yearly_interest;
double monthly_interest;
int number_payments;

double getpayment(double apr) {
    yearly_percent_int = apr;
    yearly_interest = yearly_percent_int / 100.0;
    monthly_interest = yearly_interest / 12.0;
    number_payments = number_of_years * 12;
    
    // Formula to compute monthly payment: P = L[c(1 + c)^n] / [(1 + c)^n - 1]
    // where P is the monthly payment, L is the loan amount, c is the monthly interest rate, and n is the number of payments
    double monthly_payment = loan_amount * monthly_interest / (1 - pow(1 + monthly_interest, -number_payments));
    return monthly_payment;
}

void print(double yearly_percent_int, double payment) {
    cout << setw(20) << loan_amount << setw(25) << yearly_percent_int << setw(20) << number_of_years << setw(20) << payment << endl;
}

int main() {
    int n = 1;
    double apr1, apr2, apr3;
    double pay1, pay2, pay3;
    cout << "Welcome to the Mortgage Payment Tool of Audel Rouhi!" << endl << endl;
    cout << n++ << "=====================================================." << endl << endl;
    cout << ">> Enter 3 Annual % Interest Rate (such as 1.5  2.75  4.50):" << endl;
    cin >> apr1 >> apr2 >> apr3;
    cout << endl << n++ << "=====================================================." << endl;
    pay1 = getpayment(apr1);
    pay2 = getpayment(apr2);
    pay3 = getpayment(apr3);
    cout << endl;
    cout << setw(20) << "Loan Amount" << setw(25) << "Annual % Interest Rate" << setw(20) << "Number of Years" << setw(20) << "Monthly Payment" << endl;
    cout << setw(20) << "------------------" << setw(25) << "-----------------------" << setw(20) << "----------------------" << setw(20) << "----------------------" << endl;
    print(apr1, pay1);
    print(apr2, pay2);
    print(apr3, pay3);
    cout << endl << endl << n++ << "=====================================================." << endl;
    cout << "Thank you for using the Mortgage Payment Tool of Dr. Simon Lin!" << endl;
    cout << n++ << "=====================================================." << endl << endl;
    cout << "To really quit the game, please enter a number: " << endl;
    cin >> n;
    return 0;
}