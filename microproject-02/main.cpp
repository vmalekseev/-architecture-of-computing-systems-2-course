#include <iostream>
#include <pthread.h>
#include <unistd.h>
#include <semaphore.h>


using namespace std;

void *barber_function(void *arg);

void *customer_function(void *arg);

void *make_customer_function(void *arg);

pthread_mutex_t serveCustomer;

sem_t barberReady;
sem_t customerReady;

int totalCustomers;
double maximumServingTime;
double betweenCustomersTime;



void *barber_function(void *arg) {
    int servedCustomerCount = 0;

    while (servedCustomerCount != totalCustomers) {
        sem_wait(&customerReady);
        sem_post(&barberReady);

        pthread_mutex_lock(&serveCustomer);

        int s = rand() % (int) (maximumServingTime * 1000 + 1);
        usleep(s * 1000);
        pthread_mutex_unlock(&serveCustomer);

        cout << "Customer was served." << endl;
        servedCustomerCount++;
    }

    cout << "The working day has ended." << endl;
    pthread_exit(nullptr);
}

void *customer_function(void *arg) {
    int numberOfClient = *((int *) arg);
    printf("Customer {%d} is sleeping.\n", numberOfClient);

    sem_post(&customerReady);
    sem_wait(&barberReady);

    printf("Customer {%d} is being served. \n", numberOfClient);

    pthread_exit(nullptr);
}


void *make_customer_function(void *arg) {
    int *clientNumbers = new int[totalCustomers];
    for (int i = 0; i < totalCustomers; ++i) {
        clientNumbers[i] = i + 1;
        pthread_t customer_thread;
        pthread_create(&customer_thread, nullptr, customer_function, &clientNumbers[i]);
        usleep((useconds_t) betweenCustomersTime * 1000000);
    }
    return nullptr;
}

int main() {
    srand(time(nullptr));

    try {
        cout << "Please enter the total customers: ";
        cin >> totalCustomers;
        if (cin.fail() || totalCustomers <= 0) {
            throw "Incorrect number of total customers!";
        }

        cout << "Please enter the maximum served time (s): ";
        cin >> maximumServingTime;
        if (cin.fail() || maximumServingTime <= 0) {
            throw "Incorrect number of maximum serving time!";
        }

        cout << "Please enter the time between customers (s): ";
        cin >> betweenCustomersTime;
        if (cin.fail() || betweenCustomersTime <= 0) {
            throw "Incorrect number of time between customers!";
        }
    } catch (const char* exception) {
        cerr << exception << endl;
        return 0;
    }
    cout << "The working day has started." << endl;

    pthread_t barber;
    pthread_t customer_maker;


    pthread_mutex_init(&serveCustomer, nullptr);

    sem_init(&customerReady, 0, 0);
    sem_init(&barberReady, 0, 0);


    pthread_create(&barber, nullptr, barber_function, nullptr);

    pthread_create(&customer_maker, nullptr, make_customer_function, nullptr);

    pthread_join(barber, nullptr);
    pthread_join(customer_maker, nullptr);
}