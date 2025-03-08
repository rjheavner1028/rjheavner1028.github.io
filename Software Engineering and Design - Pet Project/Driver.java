 /*
Driver.java:
* Acts as the main program that manages user input
* Allows adding new dogs and monkeys, reserves animals
* Prints animal records. 
* It includes a menu system to interact with the user and handles the lists of rescue animals.
 */

/*
 * IMPROVEMENT NOTES:
 * ----------------------------------------------------------------------------
 * 1. No proper error handling:
 *    - There is no catching exceptions that may occur from invalid user input.
 *      For example, reading a boolean or numeric value without validation might
 *      throw an exception.
 *    - Improvement: Wrap input operations with try-catch blocks.
 *
 * 2. Lack of input validation:
 *    - There is no check to verify that the inputs (like age, weight, or reserved)
 *      are of the expected format or within an acceptable range.
 *    - Consider using methods to validate that numbers are actually numeric before
 *      assignment.
 *
 * 3. Repetitive logic:
 *    - Similar code exists in both intakeNewDog and intakeNewMonkey methods.
 *      Need to input collection into helper methods would reduce redundancy.
 *
 * 4. Planned Enhancements in Python:
 *    - Error Handling & Input Validation: Implement try-except blocks.
 *    - Use descriptive variable and function names to improve readability.
 *    - Need to add clear comments for maintainability.
 *
 * 5. Potential Issue:
 *    - In the reserveAnimal() method, the code references an undefined variable
 *      'animalList'. Consider combining dogList and monkeyList or ensuring that
 *      'animalList' is properly declared.
 * ----------------------------------------------------------------------------
 */
 


import java.util.ArrayList;
import java.util.Scanner;
import java.util.InputMismatchException;

public class Driver {

    private static ArrayList<Dog> dogList = new ArrayList<Dog>();
    private static ArrayList<Monkey> monkeyList = new ArrayList<Monkey>();

    public static void main(String[] args) {
        initializeDogList();
        initializeMonkeyList();

        Scanner scanner = new Scanner(System.in);
        boolean quit = false;
        while (!quit) {
            displayMenu();
            String selection = scanner.nextLine().toLowerCase();

            switch (selection) {
                case "1":
                    intakeNewDog(scanner);
                    break;
                case "2":
                    intakeNewMonkey(scanner);
                    break;
                case "3":
                    reserveAnimal(scanner);
                    break;
                case "4":
                    printAnimals("dog");
                    break;
                case "5":
                    printAnimals("monkey");
                    break;
                case "6":
                    printAnimals("available");
                    break;
                case "q":
                    quit = true;
                    System.out.println("Exiting application...");
                    break;
                default:
                    System.out.println("Invalid selection. Please enter a valid selection from the menu.");
            }
        }
        scanner.close();
    }

    public static void displayMenu() {
        System.out.println("\n\n");
        System.out.println("\t\t\t\tRescue Animal System Menu");
        System.out.println("[1] Intake a new dog");
        System.out.println("[2] Intake a new monkey");
        System.out.println("[3] Reserve an animal");
        System.out.println("[4] Print a list of all dogs");
        System.out.println("[5] Print a list of all monkeys");
        System.out.println("[6] Print a list of all animals that are not reserved");
        System.out.println("[q] Quit application");
        System.out.println();
        System.out.println("Enter a menu selection");
    }

    public static void initializeDogList() {
        Dog dog1 = new Dog("Spot", "German Shepherd", "male", "1", "25.6", "05-12-2019", "United States", "intake", false, "United States");
        Dog dog2 = new Dog("Rex", "Great Dane", "male", "3", "35.2", "02-03-2020", "United States", "Phase I", false, "United States");
        Dog dog3 = new Dog("Bella", "Chihuahua", "female", "4", "25.6", "12-12-2019", "Canada", "in service", true, "Canada");

        dogList.add(dog1);
        dogList.add(dog2);
        dogList.add(dog3);
    }

 // Adds monkeys to a list for testing
    public static void initializeMonkeyList() {
        Monkey monkey1 = new Monkey("Charlie", "male", "2", "7.5", "04-10-2020", "United States", "in service", false, "United States", "Guenon", "20.1", "16.2", "22.3");
        Monkey monkey2 = new Monkey("Lily", "female", "1", "6.2", "11-22-2021", "Brazil", "Phase 3", true, "United States", "Marmoset", "12.5", "9.8", "11.1");
        Monkey monkey3 = new Monkey("Max", "male", "4", "19.5", "06-15-2019", "Mexico", "in service", true, "Mexico", "Howler Monkey", "22.3", "18.6", "26.4");

        monkeyList.add(monkey1);
        monkeyList.add(monkey2);
        monkeyList.add(monkey3);
    }

    // Complete the intakeNewDog method
    // The input validation to check that the dog is not already in the list
    // is done for you
    public static void intakeNewDog(Scanner scanner) {
        System.out.println("What is the dog's name?");
        String name = scanner.nextLine();
        for(Dog dog: dogList) {
            if(dog.getName().equalsIgnoreCase(name)) {
                System.out.println("\n\nThis dog is already in our system\n\n");
                return; //returns to menu
            }
        }

        // Add the code to instantiate a new dog and add it to the appropriate list
        System.out.println("What is the dog's breed?"); // the following is to add a new dog to the system
        String breed = scanner.nextLine();
        System.out.println("What is the dog's gender?");
        String gender = scanner.nextLine();
        System.out.println("What is the dog's age?");
        String age = scanner.nextLine();
        System.out.println("What is the dog's weight?");
        String weight = scanner.nextLine();
        System.out.println("What is the dog's acquisition date?");
        String acquisitionDate = scanner.nextLine();
        System.out.println("What is the dog's acquisition country?");
        String acquisitionCountry = scanner.nextLine();
        System.out.println("What is the dog's training status?");
        String trainingStatus = scanner.nextLine();
        System.out.println("Is this dog reserved?");
        boolean reserved = scanner.nextBoolean();
        scanner.nextLine();
        System.out.println("Which country is the dog in service?");
        String inServiceCountry = scanner.nextLine();
            
        Dog dog4 = new Dog(name, breed, gender, age, weight, acquisitionDate, acquisitionCountry, trainingStatus, reserved, inServiceCountry);
        dogList.add(dog4);
        System.out.println("Your entry has been added to the Dog List.");
    }

    public static void intakeNewMonkey(Scanner scanner) {
        System.out.println("What is the monkey's name?");
        String name = scanner.nextLine();
        for (Monkey monkey: monkeyList) {
            if (monkey.getName().equalsIgnoreCase(name)) {
                System.out.println("\n\nThis monkey is already in our system\n\n");
                return;
            }
        }
    }

    // Complete reserveAnimal
    // You will need to find the animal by animal type and in service country
    public static void reserveAnimal(Scanner scanner) {
        System.out.println("What is the animal type?");
        String animalType = scanner.nextLine();
        System.out.println("What is the country in service?");
        String inServiceCountry = scanner.nextLine();

        ArrayList<Animal> availableAnimals = new ArrayList<Animal>();
        for (Animal animal : animalList) {
            if (animal instanceof Dog && animal.getInServiceCountry().equalsIgnoreCase(inServiceCountry)) {
                Dog dog = (Dog) animal;
                if (!dog.isReserved()) {
                    availableAnimals.add(dog);
                }
            } else if (animal instanceof Monkey && animal.getInServiceCountry().equalsIgnoreCase(inServiceCountry)) {
                Monkey monkey = (Monkey) animal;
                if (monkey.getSpecies().equalsIgnoreCase(animalType) && !monkey.isReserved()) {
                    availableAnimals.add(monkey);
                }
            }
        }

        if (availableAnimals.size() == 0) {
            System.out.println("\n\nNo available animals.\n\n");
        } else {
            System.out.println("\n\nAvailable animals:");
            for (Animal animal : availableAnimals) {
                System.out.println(animal);
            }
            System.out.println("\n\nEnter the name of the animal to reserve:");
            String name = scanner.nextLine();
            for (Animal animal : availableAnimals) {
                if (animal.getName().equalsIgnoreCase(name)) {
                    animal.setReserved(true);
                    System.out.println("\n\nReservation confirmed.\n\n");
                    return;
                }
            }
            System.out.println("\n\nInvalid animal name.\n\n");
        }
    }

            // Get user input for the new monkey.
    		System.out.println("What is the monkey's gender?");
    			String gender = scanner.nextLine();

    		System.out.println("What is the monkey's age?");
    			String age = scanner.nextLine();

    		System.out.println("What is the monkey's weight?");
    			String weight = scanner.nextLine();

    		System.out.println("What is the monkey's acquisition date?");
    			String acquisitionDate = scanner.nextLine();

    		System.out.println("What is the monkey's acquisition country?");
    			String acquisitionCountry = scanner.nextLine();

    		System.out.println("What is the monkey's training status?");
    			String trainingStatus = scanner.nextLine();

    boolean reserved;
    while (true) {
        System.out.println("Is this monkey reserved? (true/false)");
        String input = scanner.nextLine();
        if (input.equalsIgnoreCase("true")) {
            reserved = true;
            break;
        } else if (input.equalsIgnoreCase("false")) {
            reserved = false;
            break;
        } else {
            System.out.println("Invalid input. Please enter true or false.");
        }
    }

    System.out.println("Which country is the monkey in service?");
    String inServiceCountry = scanner.nextLine();

    System.out.println("What is the monkey's species?");
    String species = scanner.nextLine();

    System.out.println("What is the tail length?");
    String tailLength = scanner.nextLine();

    System.out.println("What is the height?");
    String height = scanner.nextLine();

    System.out.println("What is the body length?");
    String bodyLength = scanner.nextLine();

    Monkey monkey4 = new Monkey(name, gender, age, weight, acquisitionDate, acquisitionCountry, trainingStatus, reserved, inServiceCountry, species, tailLength, height, bodyLength);
    monkeyList.add(monkey4);

    System.out.println("Your entry has been added to the Monkey List.");



        // Complete printAnimals
        // Include the animal name, status, acquisition country and if the animal is reserved.
        // Remember that this method connects to three different menu items.
        // The printAnimals() method has three different outputs
        // based on the listType parameter
        // dog - prints the list of dogs
        // monkey - prints the list of monkeys
        // available - prints a combined list of all animals that are
        // fully trained ("in service") but not reserved 
        // Remember that you only have to fully implement ONE of these lists. 
        // The other lists can have a print statement saying "This option needs to be implemented".
        // To score "exemplary" you must correctly implement the "available" list.
        public static void printAnimals(String listType) {
            if (listType.equalsIgnoreCase("dog")) {
                System.out.println("List of Dogs:");
                for (Dog dog : dogList) {
                    System.out.println("Name: " + dog.getName() + " | Status: " + dog.getTrainingStatus() + " | Acquisition Country: " + dog.getAcquisitionCountry() + " | Reserved: " + dog.isReserved());
                }
            } else if (listType.equalsIgnoreCase("monkey")) {
                System.out.println("List of Monkeys:");
                for (Monkey monkey : monkeyList) {
                    System.out.println("Name: " + monkey.getName() + " | Status: " + monkey.getTrainingStatus() + " | Acquisition Country: " + monkey.getAcquisitionCountry() + " | Reserved: " + monkey.isReserved());
                }
            } else {
                System.out.println("This option needs to be implemented.");
            }
        }

