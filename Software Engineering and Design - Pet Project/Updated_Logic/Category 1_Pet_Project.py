# ================================================
#464 lines of code Java 413 lines of code with improvment and tons of comments
# ================================================

# ================================================
# Rescue Animal System
# This logic manages the intake and tracking of rescue animals (dogs, cats, monkeys)
# with functionalities for data entry, validation, and reporting.
# ================================================

import sys  # For system-level functions like exiting the application
import re  # Used in date validation
from datetime import datetime  # For date validation and formatting

# Predefined lists for structured input
countries = ["United States", "Canada", "United Kingdom", "Australia", "Germany"]  # Valid country options
weights = [f"{i}-{i+5} lbs" for i in range(0, 151, 5)]  # Generates weight categories in increments of 5 lbs
training_statuses = ["Intake/Check-in", "In-Training", "Final Stage", "Completed"]  # Different training stages

# Global data storage for animals
dogs = []    # List to store Dog objects
cats = []    # List to store Cat objects
monkeys = [] # List to store Monkey objects

# =============================================================================
# Base Class: RescueAnimal
# =============================================================================
class RescueAnimal:
    def __init__(self, name, animal_type, gender, age, weight, acquisition_date,
                 acquisition_country, training_status, reserved, in_service_country):
        # Initialize basic attributes common to all rescue animals
        self.name = name  # Animal's name
        self.animal_type = animal_type  # Type of animal
        self.gender = gender  # Gender of the animal
        self.age = age  # Age of the animal
        self.weight = weight  # Weight category of the animal
        self.acquisition_date = acquisition_date  # Date when the animal was acquired
        self.acquisition_country = acquisition_country  # Country of acquisition
        self.training_status = training_status  # Current training status
        self.reserved = reserved  # Boolean for if the animal is reserved
        self.in_service_country = in_service_country  # Country where the animal is in service

    def update_training_status(self, new_status):
        # Update the training status of the animal with a new status
        self.training_status = new_status  # Set new training status

    def __str__(self):
        # Return a string representation of the animal with key details
        base_info = (f"Name: {self.name}, Type: {self.animal_type}, Acquisition Date: {self.acquisition_date}, "
                     f"Training Status: {self.training_status}, Reserved: {self.reserved}")
        # Breed for Dog/Cat or species and extra details for Monkey if available
        if hasattr(self, 'breed'):  # Check if the animal has a 'breed' attribute (Dogs and Cats)
            base_info += f", Breed: {self.breed}"
        elif hasattr(self, 'species'):  # Check if the animal has a 'species' attribute (Monkey)
            base_info += (f", Species: {self.species}, Tail Length: {self.tail_length} in, "
                          f"Height: {self.height} in, Body Length: {self.body_length} in")
        return base_info  # Return the compiled string

# =============================================================================
# Subclass: Dog
# =============================================================================
class Dog(RescueAnimal):
    def __init__(self, name, breed, gender, age, weight, acquisition_date,
                 acquisition_country, training_status, reserved, in_service_country):
        # Initialize a Dog object using the RescueAnimal base class
        super().__init__(name, "Dog", gender, age, weight, acquisition_date,
                         acquisition_country, training_status, reserved, in_service_country)
        self.breed = breed  # Specific attribute for dogs: breed

# =============================================================================
# Subclass: Cat
# =============================================================================
class Cat(RescueAnimal):
    def __init__(self, name, breed, gender, age, weight, acquisition_date,
                 acquisition_country, training_status, reserved, in_service_country):
        # Initialize a Cat object using the RescueAnimal base class
        super().__init__(name, "Cat", gender, age, weight, acquisition_date,
                         acquisition_country, training_status, reserved, in_service_country)
        self.breed = breed  # Specific attribute for cats: breed

# =============================================================================
# Subclass: Monkey
# =============================================================================
class Monkey(RescueAnimal):
    def __init__(self, name, species, gender, age, weight, acquisition_date,
                 acquisition_country, training_status, reserved, in_service_country,
                 tail_length, height, body_length):
        # Initialize a Monkey object using the RescueAnimal base class
        super().__init__(name, "Monkey", gender, age, weight, acquisition_date,
                         acquisition_country, training_status, reserved, in_service_country)
        self.species = species  # Specific attribute for monkeys: species
        self.tail_length = tail_length  # Specific measurement: tail length in inches
        self.height = height  # Specific measurement: height in inches
        self.body_length = body_length  # Specific measurement: body length in inches

# =============================================================================
# Helper Functions for Validated Input
# =============================================================================
def get_valid_input(prompt, choices):
    """Helper function to get a valid choice from a list.
    
    Displays options from the provided choices list, allows manual entry,
    and ensures a valid option is returned.
    """
    while True:
        print(f"\n{prompt}")
        # Display each choice with an index number for selection
        for idx, option in enumerate(choices, 1):
            print(f"[{idx}] {option}")
        print("[0] Other (Enter manually)")  # Option to enter a new value not in the list
        choice = input("Select an option: ").strip()
        if choice.isdigit():
            choice = int(choice)
            # Check if selection is within the valid range of choices
            if 1 <= choice <= len(choices):
                return choices[choice - 1]  # Return the selected option
            elif choice == 0:
                new_entry = input("Enter a new option: ").strip().title()
                if new_entry not in choices:
                    choices.append(new_entry)  # Save new entry for future selections
                return new_entry  # Return the newly added option
        print("Invalid input. Please enter a valid option.")

def get_valid_date(prompt):
    """Ensures the user enters a valid date format (MM-DD-YYYY).
    
    Uses regular expressions and datetime parsing for validation.
    """
    while True:
        date_input = input(f"{prompt} (Format: MM-DD-YYYY): ").strip()
        # Check if the input matches the date pattern
        if re.match(r"^(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])-\d{4}$", date_input):
            try:
                datetime.strptime(date_input, "%m-%d-%Y")  # Validate by parsing
                return date_input  # Return the valid date string
            except ValueError:
                pass  # Continue to error message if date is invalid
        print("Invalid date format. Please enter in MM-DD-YYYY format.")

def get_yes_no(prompt):
    """Ensures a Yes/No response.
    
    Repeats prompt until user enters 'yes' or 'no', returns True for yes.
    """
    while True:
        response = input(f"{prompt} (yes/no): ").strip().lower()
        if response in ["yes", "no"]:
            return response == "yes"  # True if 'yes', False if 'no'
        print("Invalid input. Please enter 'yes' or 'no'.")

# =============================================================================
# Animal Intake Process
# =============================================================================
def intake_new_animal(animal_type):
    """Guided process to intake a new animal.
    
    Collects and validates user input, prevents duplicate names,
    and adds the new animal to the appropriate global list.
    """
    while True:
        print(f"\n--- Adding a New {animal_type} ---")

        # Prompt user for animal's name and remove leading/trailing whitespace
        name = input(f"Enter the {animal_type}'s name: ").strip()
        # Check for duplicate names (case-insensitive) among all animals
        existing_names = [animal.name.lower() for animal in (dogs + cats + monkeys)]
        if name.lower() in existing_names:
            print("\nThis name is already in the system. Please choose another.\n")
            continue  # Restart process if duplicate found

        # For Dog/Cat: ask for breed; for Monkey: ask for species
        breed_species = input(f"Enter the {animal_type}'s {'breed' if animal_type in ['Dog', 'Cat'] else 'species'}: ").strip()
        gender = get_valid_input("Select gender:", ["Male", "Female"])  # Validate gender selection
        age = input("Enter age in years: ").strip()  # Age entered as string
        weight = get_valid_input("Select weight range:", weights)  # Validate weight range selection
        acquisition_date = get_valid_date("Enter acquisition date")  # Validate date input
        acquisition_country = get_valid_input("Select acquisition country:", countries)  # Validate country selection
        training_status = get_valid_input("Select training status:", training_statuses)  # Validate training status
        reserved = get_yes_no("Is this animal reserved?")  # Validate Yes/No input for reservation status
        in_service_country = get_valid_input("Select in-service country:", countries)  # Validate in-service country selection

        # Collect additional details for Monkeys
        if animal_type == "Monkey":
            tail_length = input("Enter tail length (in inches): ").strip()  # Get tail length
            height = input("Enter height (in inches): ").strip()  # Get height
            body_length = input("Enter body length (in inches): ").strip()  # Get body length

        # Display all collected details for review before saving
        print("\n--- Review Entered Details ---")
        print(f"Name: {name}")
        print(f"Type: {animal_type}")
        print(f"Breed/Species: {breed_species}")
        print(f"Gender: {gender}")
        print(f"Age: {age} years")
        print(f"Weight: {weight}")
        print(f"Acquisition Date: {acquisition_date}")
        print(f"Acquisition Country: {acquisition_country}")
        print(f"Training Status: {training_status}")
        print(f"Reserved: {'Yes' if reserved else 'No'}")
        print(f"In-Service Country: {in_service_country}")
        if animal_type == "Monkey":
            print(f"Tail Length: {tail_length} inches")
            print(f"Height: {height} inches")
            print(f"Body Length: {body_length} inches")

        # Confirm that the information is correct before saving
        if get_yes_no("Is this information correct?"):
            # Depending on animal type, create and add the animal to the respective list
            if animal_type == "Dog":
                dogs.append(Dog(name, breed_species, gender, age, weight,
                                acquisition_date, acquisition_country, training_status,
                                reserved, in_service_country))
            elif animal_type == "Cat":
                cats.append(Cat(name, breed_species, gender, age, weight,
                                acquisition_date, acquisition_country, training_status,
                                reserved, in_service_country))
            else:  # For Monkey type
                monkeys.append(Monkey(name, breed_species, gender, age, weight,
                                      acquisition_date, acquisition_country, training_status,
                                      reserved, in_service_country, tail_length, height, body_length))
            print("\nNew animal has been added to the system.\n")
            return  # Exit the intake process after successful entry
        else:
            print("\nRestarting entry process...\n")
            # Loop will restart for re-entry of information

# =============================================================================
# Data Initialization Function - Sample Data for project purposes
# =============================================================================
def initialize_data():
    """Initializes the application with sample data for dogs, cats, and monkeys.
    
    This function pre-loads the system with sample animal records for demonstration.
    """
    global dogs, cats, monkeys  # Declare usage of global lists

    # Sample Dogs
    dogs.append(Dog("Spot", "German Shepherd", "Male", "3", "60-65 lbs", "05-12-2020",
                    "United States", "In-Training", False, "United States"))
    dogs.append(Dog("Luna", "Labrador Retriever", "Female", "4", "55-60 lbs", "03-18-2019",
                    "Canada", "Final Stage", True, "Canada"))
    dogs.append(Dog("Max", "Golden Retriever", "Male", "2", "50-55 lbs", "07-25-2021",
                    "United Kingdom", "Completed", False, "United Kingdom"))

    # Sample Cats
    cats.append(Cat("Whiskers", "Maine Coon", "Male", "5", "10-15 lbs", "08-12-2018",
                    "United States", "Completed", False, "United States"))
    cats.append(Cat("Misty", "Siamese", "Female", "3", "8-10 lbs", "10-30-2020",
                    "Australia", "In-Training", True, "Australia"))
    cats.append(Cat("Shadow", "British Shorthair", "Male", "4", "12-15 lbs", "12-05-2019",
                    "Germany", "Final Stage", False, "Germany"))

    # Sample Monkeys
    monkeys.append(Monkey("Charlie", "Guenon", "Male", "2", "20-25 lbs", "04-10-2021",
                            "United States", "In-Training", False, "United States",
                            "20.1", "16.2", "22.3"))
    monkeys.append(Monkey("Lily", "Marmoset", "Female", "1", "10-15 lbs", "11-22-2022",
                            "Canada", "Final Stage", True, "Canada",
                            "12.5", "9.8", "11.1"))
    monkeys.append(Monkey("Max", "Howler Monkey", "Male", "4", "25-30 lbs", "06-15-2019",
                            "United Kingdom", "Completed", False, "United Kingdom",
                            "22.3", "18.6", "26.4"))

# =============================================================================
# Reporting Functions: Print Animal Data
# =============================================================================
def print_training_status():
    """Prints the training status of all animals grouped by type.
    
    Displays a categorized list of animals along with their current training status.
    """
    print("\n--- Training Status for All Animals ---")
    if not dogs and not cats and not monkeys:
        print("No animals in the system.")
        return

    # Print training status for Dogs
    print("\n🐕 Dogs:")
    if dogs:
        for dog in dogs:
            print(f"- {dog.name}: {dog.training_status}")  # Inline: Display each dog's name and training status
    else:
        print("No dogs available.")

    # Print training status for Cats
    print("\n🐈 Cats:")
    if cats:
        for cat in cats:
            print(f"- {cat.name}: {cat.training_status}")  # Inline: Display each cat's name and training status
    else:
        print("No cats available.")

    # Print training status for Monkeys
    print("\n🐒 Monkeys:")
    if monkeys:
        for monkey in monkeys:
            print(f"- {monkey.name}: {monkey.training_status}")  # Inline: Display each monkey's name and training status
    else:
        print("No monkeys available.")
    print()  # Extra newline for spacing

def print_all_animals():
    """Prints all animals in the system with their details."""
    print("\n--- All Animals in the System ---")
    all_animals = dogs + cats + monkeys  # Combine all animal lists
    if not all_animals:
        print("No animals in the system.")
        return
    for animal in all_animals:
        print(animal)  # Uses the __str__ method of each animal for formatting
    print()

def print_list_of_dogs():
    """Prints a list of all dogs."""
    print("\n--- List of Dogs ---")
    if not dogs:
        print("No dogs available.")
    else:
        for dog in dogs:
            print(dog)  # Display each dog's details
    print()

def print_list_of_cats():
    """Prints a list of all cats."""
    print("\n--- List of Cats ---")
    if not cats:
        print("No cats available.")
    else:
        for cat in cats:
            print(cat)  # Display each cat's details
    print()

def print_list_of_monkeys():
    """Prints a list of all monkeys."""
    print("\n--- List of Monkeys ---")
    if not monkeys:
        print("No monkeys available.")
    else:
        for monkey in monkeys:
            print(monkey)  # Display each monkey's details
    print()

def print_list_of_available_animals():
    """Prints animals that are available for service (i.e., training completed and not reserved)."""
    print("\n--- List of Available Animals ---")
    # Filter animals that have completed training and are not reserved
    available = [animal for animal in (dogs + cats + monkeys)
                 if animal.training_status == "Completed" and not animal.reserved]
    if not available:
        print("No available animals.")
    else:
        for animal in available:
            print(animal)  # Display details of available animals
    print()

# =============================================================================
# Main Menu Functionality
# =============================================================================
def display_menu():
    """Displays the main menu and handles user input to navigate the system.
    
    Calls the data initialization function and presents menu options
    for various functionalities like intake, listing, and status reports.
    """
    initialize_data()  # Load sample data into the system

    while True:
        # Display menu options to the user
        print("\nRescue Animal System Menu")
        print("[1] Intake a new dog")
        print("[2] Intake a new cat")
        print("[3] Intake a new monkey")
        print("[4] Print list of all dogs")
        print("[5] Print list of all cats")
        print("[6] Print list of all monkeys")
        print("[7] Print list of available animals")
        print("[8] Print Training Status for All Animals")
        print("[9] Print All Animals")
        print("[q] Quit")

        choice = input("Enter your choice: ").strip().lower()  # Get user's menu selection
        # Execute functionality based on user's menu choice
        if choice == "1":
            intake_new_animal("Dog")
        elif choice == "2":
            intake_new_animal("Cat")
        elif choice == "3":
            intake_new_animal("Monkey")
        elif choice == "4":
            print_list_of_dogs()
        elif choice == "5":
            print_list_of_cats()
        elif choice == "6":
            print_list_of_monkeys()
        elif choice == "7":
            print_list_of_available_animals()
        elif choice == "8":
            print_training_status()
        elif choice == "9":
            print_all_animals()
        elif choice == "q":
            print("Exiting the application...")
            sys.exit()  # Terminate the application
        else:
            print("Invalid choice. Please try again.")

# =============================================================================
# Entry Point of the Application
# =============================================================================
if __name__ == "__main__":
    display_menu()  # Start the application by displaying the menu

