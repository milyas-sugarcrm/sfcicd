public class QuestionFieldMapping {
  public String question { get; set; }
  public String fieldName { get; set; }

  public QuestionFieldMapping(String question, String fieldName) {
    this.question = question;
    this.fieldName = fieldName;
  }
}
