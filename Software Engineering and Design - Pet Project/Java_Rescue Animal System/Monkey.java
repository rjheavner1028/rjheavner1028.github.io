 /*
Monkey.java:
* Extends the RescueAnimal class to represent a monkey, adding attributes specific to monkeys such as species, tail length, height, and body length.
 */

/*
 * IMPROVEMENT NOTES:
 * ----------------------------------------------------------------------------
 * 1. No proper error handling:
 *    - The setter methods do not include any checks to ensure that the inputs
 *      (tailLength, height, bodyLength) are valid.
 *
 * 2. Lack of input validation:
 *    - Since measurements are kept as strings, there is no verification that they
 *      represent valid numeric values. Parsing and validating these would be
 *      beneficial.
 *
 * 3. Planned Python Enhancements:
 *    - The Python version can enforce type checking and use try-except blocks
 *      for converting user input.
 * ----------------------------------------------------------------------------
 */
 


public class Monkey extends RescueAnimal {
    private String species;
    private String tailLength;
    private String height;
    private String bodyLength;

    public Monkey(String species, String tailLength, String height, String bodyLength) {
        setSpecies(species);
        setTailLength(tailLength);
        setHeight(height);
        setBodyLength(bodyLength);
    }

    public String getSpecies() {
        return species;
    }

    public void setSpecies(String species) {
        this.species = species;
    }

    public String getTailLength() {
        return tailLength;
    }

    public void setTailLength(String tailLength) {
        this.tailLength = tailLength;
    }

    public String getHeight() {
        return height;
    }

    public void setHeight(String height) {
        this.height = height;
    }

    public String getBodyLength() {
        return bodyLength;
    }

    public void setBodyLength(String bodyLength) {
        this.bodyLength = bodyLength;
    }
}
