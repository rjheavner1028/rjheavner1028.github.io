  /*
Dog.java:
* Extends the RescueAnimal class to represent a dog, adding a specific attribute for the breed of the dog.
 */

/*
 * IMPROVEMENT NOTES:
 * ----------------------------------------------------------------------------
 * 1. No proper error handling:
 *    - Currently, there is no try-catch logic when setting properties. In a
 *      real-world scenario, invalid inputs (null or incorrect type) could
 *      cause unexpected crashes.
 *    - Planned improvement (Python): Use try-except blocks to handle exceptions.
 *
 * 2. Lack of input validation:
 *    - The 'breed' and other parameters are directly assigned without checking
 *      for null, empty strings, or invalid formats.
 *    - Need to add validation methods or helper functions to ensure data
 *      integrity.
 *
 * 3. Repetitive logic:
 *    - Although this class is concise, similar validations are needed in
 *      other classes this could be combined.
 *
 * 4. Code:
 *    - Java tends to be more verbose than Python. The planned Python version
 *      can achieve the same functionality in fewer lines.
 *
 * ----------------------------------------------------------------------------
 */
 


public class Dog extends RescueAnimal {

    // Instance variable
    private String breed;

    // Constructor
    public Dog(String name, String breed, String gender, String age,
    String weight, String acquisitionDate, String acquisitionCountry,
	String trainingStatus, boolean reserved, String inServiceCountry) {
        setName(name);
        setBreed(breed);
        setGender(gender);
        setAge(age);
        setWeight(weight);
        setAcquisitionDate(acquisitionDate);
        setAcquisitionLocation(acquisitionCountry);
        setTrainingStatus(trainingStatus);
        setReserved(reserved);
        setInServiceCountry(inServiceCountry);
    }

    // Accessor Method
    public String getBreed() {
        return breed;
    }

    // Mutator Method
    public void setBreed(String dogBreed) {
        breed = dogBreed;
    }
}
