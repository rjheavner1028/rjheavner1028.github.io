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
