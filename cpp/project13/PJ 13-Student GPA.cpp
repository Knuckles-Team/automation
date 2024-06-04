#include <iostream>
#include <iomanip>
#include <string>

using namespace std;

static int countStudents = 0;  // count the total number of students being constructed 
static double totalGpa = 0.0;  // total GPA sum of all students
static double averageGpa = 0.0;  // average GPA of all students
static string sidA[12];  // 5 stat5ic parallel arrays of 12 items each
static string lnameA[12];
static string fnameA[12];
static double gpaA[12];s

static string phoneA[12];

class Student {
private:
    string studentID;
    string lastName;
    string firstName;
    double gpa;
    string phoneNumber;

public:
    Student(string id, string lname, string fname, double g, string phone) {
        studentID = id;
        lastName = lname;
        firstName = fname;
        gpa = g;
        phoneNumber = phone;

        // Increment student count
        countStudents++;

        // Update GPA total and average
        totalGpa += gpa;
        averageGpa = totalGpa / countStudents;

        // Print the complete record for this new student
        cout << "Student id: " << studentID 
             << ", Last Name: " << lastName 
             << ", First Name: " << firstName 
             << ", GPA: " << fixed << setprecision(2) << gpa 
             << ", Phone Number: " << phoneNumber << endl;

        // Add this student record to the static parallel arrays
        int index = countStudents - 1;
        sidA[index] = studentID;
        lnameA[index] = lastName;
        fnameA[index] = firstName;
        gpaA[index] = gpa;
        phoneA[index] = phoneNumber;
    }

    static void printReport() {
        cout << "Student GPA Report:" << endl;
        cout << "ID\tLast Name\tFirst Name\tGPA\tPhone Number" << endl;
        cout << "-----\t-----------------\t----------------------\t----------\t---------------------" << endl;
        for (int i = 0; i < countStudents; ++i) {
            cout << sidA[i] << "\t" 
                 << lnameA[i] << "\t" 
                 << fnameA[i] << "\t" 
                 << fixed << setprecision(2) << gpaA[i] << "\t" 
                 << phoneA[i] << endl;
        }
        cout << "\nThe average GPA of the above " << countStudents << " students is " << fixed << setprecision(2) << averageGpa << endl;
    }
};

int main() {
    cout << "Welcome to the Student GPA System of Karlos Huschke-Favela!" << endl;
    cout << "1=========================================================." << endl;
    
    while (true) {
        string studentID, lastName, firstName, phoneNumber;
        double gpa;
        
        cout << ">> Please enter student id, last name, first name, GPA, and phone number>" << endl;
        cin >> studentID >> lastName >> firstName >> gpa >> phoneNumber;
        
        if (studentID == "0") {
            break;
        }
        
        Student student(studentID, lastName, firstName, gpa, phoneNumber);
        cout << "Current Student Count: " << countStudents 
             << ", Total GPA: " << fixed << setprecision(2) << totalGpa 
             << ", Average GPA: " << fixed << setprecision(2) << averageGpa << endl;
        cout << "=========================================================." << endl;
    }
    
    cout << "=========================================================." << endl;
    Student::printReport();
    cout << "=========================================================." << endl;
    cout << "Thank you for using the Student GPA System of Karlos Huschke-Favela!" << endl;
    cout << "=========================================================." << endl;

    return 0;
}
