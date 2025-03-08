import sys
import re
from datetime import datetime

# Predefined lists for structured input
countries = ["United States", "Canada", "United Kingdom", "Australia", "Germany"]
weights = [f"{i}-{i+5} lbs" for i in range(0, 151, 5)]  # Weight categories in increments of 5 lbs
training_statuses = ["Intake/Check-in", "In-Training", "Final Stage", "Completed"]

# Global data storage for animals
dogs = []
cats = []
monkeys = []

# Base class for Rescue Animals
class RescueAnimal:
    def __init__(self, name, animal_type, gender, age, weight, acquisition_date,
                 acquisition_country, training_status, reserved, in_service_country):
        self.name = name
        self.animal_type = animal_type
        self.gender = gender
        self.age = age
        self.weight = weight
        self.acquisition_date = acquisition_date
        self.acquisition_country = acquisition_country
        self.training_status = training_status
        self.reserved = reserved
        self.in_service_country = in_service_country

    def update_training_status(self, new_status):
        self.training_status = new_status

    def __str__(self):
        base_info = (f"Name: {self.name}, Type: {self.animal_type}, Acquisition Date: {self.acquisition_date}, "
                     f"Training Status: {self.training_status}, Reserved: {self.reserved}")
        # Append breed for Dog/Cat or species and extra details for Monkey if available
        if hasattr(self, 'breed'):
            base_info += f", Breed: {self.breed}"
        elif hasattr(self, 'species'):
            base_info += (f", Species: {self.species}, Tail Length: {self.tail_length} in, "
                          f"Height: {self.height} in, Body Length: {self.body_length} in")
        return base_info

# Dog subclass
class Dog(RescueAnimal):
    def __init__(self, name, breed, gender, age, weight, acquisition_date,
                 acquisition_country, training_status, reserved, in_service_country):
        super().__init__(name, "Dog", gender, age, weight, acquisition_date,
                         acquisition_country, training_status, reserved, in_service_country)
        self.breed = breed

# Cat subclass
class Cat(RescueAnimal):
    def __init__(self, name, breed, gender, age, weight, acquisition_date,
                 acquisition_country, training_status, reserved, in_service_country):
        super().__init__(name, "Cat", gender, age, weight, acquisition_date,
                         acquisition_country, training_status, reserved, in_service_country)
        self.breed = breed

# Monkey subclass
class Monkey(RescueAnimal):
    def __init__(self, name, species, gender, age, weight, acquisition_date,
                 acquisition_country, training_status, reserved, in_service_country,
                 tail_length, height, body_length):
        super().__init__(name, "Monkey", gender, age, weight, acquisition_date,
                         acquisition_country, training_status, reserved, in_service_country)
        self.species = species
        self.tail_length = tail_length
        self.height = height
        self.body_length = body_length

# Helper functions for validated input
def get_valid_input(prompt, choices):
    """Helper function to get a valid choice from a list."""
    while True:
        print(f"\n{prompt}")
        for idx, option in enumerate(choices, 1):
            print(f"[{idx}] {option}")
        print("[0] Other (Enter manually)")
        choice = input("Select an option: ").strip()
        if choice.isdigit():
            choice = int(choice)
            if 1 <= choice <= len(choices):
                return choices[choice - 1]
            elif choice == 0:
                new_entry = input("Enter a new option: ").strip().title()
                if new_entry not in choices:
                    choices.append(new_entry)  # Save new entry for future selections
                return new_entry
        print("Invalid input. Please enter a valid option.")

def get_valid_date(prompt):
    """Ensures the user enters a valid date format (MM-DD-YYYY)."""
    while True:
        date_input = input(f"{prompt} (Format: MM-DD-YYYY): ").strip()
        if re.match(r"^(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])-\d{4}$", date_input):
            try:
                datetime.strptime(date_input, "%m-%d-%Y")
                return date_input
            except ValueError:
                pass
        print("Invalid date format. Please enter in MM-DD-YYYY format.")

def get_yes_no(prompt):
    """Ensures a Yes/No response."""
    while True:
        response = input(f"{prompt} (yes/no): ").strip().lower()
        if response in ["yes", "no"]:
            return response == "yes"
        print("Invalid input. Please enter 'yes' or 'no'.")

# Intake process for a new animal with validation and review
def intake_new_animal(animal_type):
    """Guided process to intake a new animal."""
    while True:
        print(f"\n--- Adding a New {animal_type} ---")

        name = input(f"Enter the {animal_type}'s name: ").strip()
        # Check for duplicate names (case-insensitive) among all animals
        existing_names = [animal.name.lower() for animal in (dogs + cats + monkeys)]
        if name.lower() in existing_names:
            print("\nThis name is already in the system. Please choose another.\n")
            continue

        # For Dog/Cat: ask for breed; for Monkey: ask for species
        breed_species = input(f"Enter the {animal_type}'s {'breed' if animal_type in ['Dog', 'Cat'] else 'species'}: ").strip()
        gender = get_valid_input("Select gender:", ["Male", "Female"])
        age = input("Enter age in years: ").strip()
        weight = get_valid_input("Select weight range:", weights)
        acquisition_date = get_valid_date("Enter acquisition date")
        acquisition_country = get_valid_input("Select acquisition country:", countries)
        training_status = get_valid_input("Select training status:", training_statuses)
        reserved = get_yes_no("Is this animal reserved?")
        in_service_country = get_valid_input("Select in-service country:", countries)

        # Collect additional details for Monkeys
        if animal_type == "Monkey":
            tail_length = input("Enter tail length (in inches): ").strip()
            height = input("Enter height (in inches): ").strip()
            body_length = input("Enter body length (in inches): ").strip()

        # Review entered details before saving
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

        if get_yes_no("Is this information correct?"):
            if animal_type == "Dog":
                dogs.append(Dog(name, breed_species, gender, age, weight,
                                acquisition_date, acquisition_country, training_status,
                                reserved, in_service_country))
            elif animal_type == "Cat":
                cats.append(Cat(name, breed_species, gender, age, weight,
                                acquisition_date, acquisition_country, training_status,
                                reserved, in_service_country))
            else:  # Monkey
                monkeys.append(Monkey(name, breed_species, gender, age, weight,
                                      acquisition_date, acquisition_country, training_status,
                                      reserved, in_service_country, tail_length, height, body_length))
            print("\nNew animal has been added to the system.\n")
            return
        else:
            print("\nRestarting entry process...\n")

# Initialize sample data for the system
def initialize_data():
    """Initializes the application with sample data for dogs, cats, and monkeys."""
    global dogs, cats, monkeys

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

# Function to print training status of all animals, grouped by type
def print_training_status():
    """Prints the training status of all animals."""
    print("\n--- Training Status for All Animals ---")
    if not dogs and not cats and not monkeys:
        print("No animals in the system.")
        return

    print("\n🐕 Dogs:")
    if dogs:
        for dog in dogs:
            print(f"- {dog.name}: {dog.training_status}")
    else:
        print("No dogs available.")

    print("\n🐈 Cats:")
    if cats:
        for cat in cats:
            print(f"- {cat.name}: {cat.training_status}")
    else:
        print("No cats available.")

    print("\n🐒 Monkeys:")
    if monkeys:
        for monkey in monkeys:
            print(f"- {monkey.name}: {monkey.training_status}")
    else:
        print("No monkeys available.")
    print()

# Listing functions
def print_all_animals():
    """Prints all animals in the system."""
    print("\n--- All Animals in the System ---")
    all_animals = dogs + cats + monkeys
    if not all_animals:
        print("No animals in the system.")
        return
    for animal in all_animals:
        print(animal)
    print()

def print_list_of_dogs():
    print("\n--- List of Dogs ---")
    if not dogs:
        print("No dogs available.")
    else:
        for dog in dogs:
            print(dog)
    print()

def print_list_of_cats():
    print("\n--- List of Cats ---")
    if not cats:
        print("No cats available.")
    else:
        for cat in cats:
            print(cat)
    print()

def print_list_of_monkeys():
    print("\n--- List of Monkeys ---")
    if not monkeys:
        print("No monkeys available.")
    else:
        for monkey in monkeys:
            print(monkey)
    print()

def print_list_of_available_animals():
    """Prints animals that are available for service (i.e., training completed and not reserved)."""
    print("\n--- List of Available Animals ---")
    available = [animal for animal in (dogs + cats + monkeys)
                 if animal.training_status == "Completed" and not animal.reserved]
    if not available:
        print("No available animals.")
    else:
        for animal in available:
            print(animal)
    print()

# Main menu to drive the system
def display_menu():
    """Displays the main menu and handles user input."""
    initialize_data()  # Load sample data

    while True:
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

        choice = input("Enter your choice: ").strip().lower()
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
            sys.exit()
        else:
            print("Invalid choice. Please try again.")

# Run the system
if __name__ == "__main__":
    display_menu()
