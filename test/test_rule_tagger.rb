require File.dirname(__FILE__) + '/test_helper'


class TestRuleTagger< Test::Unit::TestCase
SAMPLE_DOC=%q(
Take an active role in your care
When it comes to making decisions about the goals and direction of treatment, don't sit back. Work closely and actively with your oncologist and the rest of your medical team.
Dont overlook clinical trials
If youre eligible to enroll in clinical trials, select an oncologist who participates in them. Patients who enroll in clinical studies receive closer follow-up, the highest standard-of-care treatment and access to experimental therapies at no extra cost.
Maximize your nutrition strategy
Doing your best to eat a healthy, well-balanced diet is vital to prompt healing after surgery and for recovery from radiation or chemotherapy. Many oncology practices employ registered dieticians who can help you optimize your nutrition.
Steer clear of "natural cures"
Before trying nutritional supplements or herbal remedies, be sure to discuss your plans with a doctor. Most have not been tested in clinical studies, and some may actually interfere with your treatment.
Build a stronger body
Even walking regularly is can help you minimize long-term muscle weakness caused by illness or de-conditioning.
Focus on overall health
Patients may be cured of cancer but still face life-threatening medical problems that are underemphasized during cancer treatments, such as diabetes, high blood pressure and heart disease. Continue to monitor your overall health.
Put the fire out for good
Smoking impairs healing after surgery and radiation and increases your risk of cardiovascular disease and many types of cancers. Ask your doctor for help identifying and obtaining the most appropriate cessation aids.
Map a healthy future
Once youve completed treatment, discuss appropriate follow-up plans with your doctor and keep track of them yourself. Intensified screening over many years is frequently recommended to identify and treat a recurrence early on.
Share your feelings
Allow yourself time to discuss the emotional consequences of your illness and treatment with family, friends, your doctor and, if necessary, a professional therapist. Many patients also find antidepressants helpful during treatment.
Stay connected
Although many newly diagnosed patients fear they will not be able to keep working during treatment, this is usually not the case. Working, even at a reduced schedule, helps you maintain valuable social connections and weekly structure.
)
  def setup
    if !defined?($tagger)
      puts "loading tagger..."
      $rtagger = Brill::Tagger.new( File.join(File.dirname(__FILE__),"LEXICON"),
                                   File.join(File.dirname(__FILE__),"LEXICALRULEFILE"),
                                   File.join(File.dirname(__FILE__),"CONTEXTUALRULEFILE") )
      puts "tagger loaded!"
    end
  end

  def test_simple_tagger
    pairs = tagger.tag( SAMPLE_DOC )
    assert_equal [["", ")"], ["", ")"], ["Take", "VB"], ["an", "DT"], ["active", "JJ"], ["role", "NN"], ["in", "IN"], ["your", "PRP$"], ["care", "NN"], ["When", "WRB"], ["it", "PRP"], ["comes", "VBZ"], ["to", "TO"], ["making", "VBG"], ["decisions", "NNS"], ["about", "IN"], ["the", "DT"], ["goals", "NNS"], ["and", "CC"], ["direction", "NN"], ["of", "IN"], ["treatment", "NN"], [",", ","], ["", ")"], ["do", "VBP"], ["", ")"], ["n't", "RB"], ["sit", "VB"], ["back.", "CD"], ["Work", "NN"], ["closely", "RB"], ["and", "CC"], ["actively", "RB"], ["with", "IN"], ["your", "PRP$"], ["oncologist", "NN"], ["and", "CC"], ["the", "DT"], ["rest", "NN"], ["of", "IN"], ["your", "PRP$"], ["medical", "JJ"], ["team.", "NNP"], ["Dont", "NNP"], ["overlook", "VB"], ["clinical", "JJ"], ["trials", "NNS"], ["If", "IN"], ["youre", "NN"], ["eligible", "JJ"], ["to", "TO"], ["enroll", "VB"], ["in", "IN"], ["clinical", "JJ"], ["trials", "NNS"], [",", ","], ["", ")"], ["select", "VB"], ["an", "DT"], ["oncologist", "NN"], ["who", "WP"], ["participates", "VBZ"], ["in", "IN"], ["them.", "JJ"], ["Patients", "NNS"], ["who", "WP"], ["enroll", "VBP"], ["in", "IN"], ["clinical", "JJ"], ["studies", "NNS"], ["receive", "VBP"], ["closer", "JJR"], ["follow-up", "NN"], [",", ","], ["", ")"], ["the", "DT"], ["highest", "JJS"], ["standard-of-care", "JJ"], ["treatment", "NN"], ["and", "CC"], ["access", "NN"], ["to", "TO"], ["experimental", "JJ"], ["therapies", "NNS"], ["at", "IN"], ["no", "DT"], ["extra", "JJ"], ["cost.", "NNP"], ["Maximize", "NNP"], ["your", "PRP$"], ["nutrition", "NN"], ["strategy", "NN"], ["Doing", "NNP"], ["your", "PRP$"], ["best", "JJS"], ["to", "TO"], ["eat", "VB"], ["a", "DT"], ["healthy", "JJ"], [",", ","], ["", ")"], ["well-balanced", "JJ"], ["diet", "NN"], ["is", "VBZ"], ["vital", "JJ"], ["to", "TO"], ["prompt", "VB"], ["healing", "NN"], ["after", "IN"], ["surgery", "NN"], ["and", "CC"], ["for", "IN"], ["recovery", "NN"], ["from", "IN"], ["radiation", "NN"], ["or", "CC"], ["chemotherapy.", "JJ"], ["Many", "JJ"], ["oncology", "NN"], ["practices", "NNS"], ["employ", "VBP"], ["registered", "VBN"], ["dieticians", "NNS"], ["who", "WP"], ["can", "MD"], ["help", "VB"], ["you", "PRP"], ["optimize", "VB"], ["your", "PRP$"], ["nutrition.", "JJ"], ["Steer", "VB"], ["clear", "JJ"], ["of", "IN"], ["", ")"], ["``", "``"], ["natural", "JJ"], ["cures", "NNS"], ["''", "''"], ["", ")"], ["Before", "IN"], ["trying", "VBG"], ["nutritional", "JJ"], ["supplements", "NNS"], ["or", "CC"], ["herbal", "JJ"], ["remedies", "NNS"], [",", ","], ["", ")"], ["be", "VB"], ["sure", "JJ"], ["to", "TO"], ["discuss", "VB"], ["your", "PRP$"], ["plans", "NNS"], ["with", "IN"], ["a", "DT"], ["doctor.", "JJ"], ["Most", "JJS"], ["have", "VBP"], ["not", "RB"], ["been", "VBN"], ["tested", "VBN"], ["in", "IN"], ["clinical", "JJ"], ["studies", "NNS"], [",", ","], ["", ")"], ["and", "CC"], ["some", "DT"], ["may", "MD"], ["actually", "RB"], ["interfere", "VB"], ["with", "IN"], ["your", "PRP$"], ["treatment.", "JJ"], ["Build", "VB"], ["a", "DT"], ["stronger", "JJR"], ["body", "NN"], ["Even", "RB"], ["walking", "VBG"], ["regularly", "RB"], ["is", "VBZ"], ["can", "MD"], ["help", "VB"], ["you", "PRP"], ["minimize", "VB"], ["long-term", "JJ"], ["muscle", "NN"], ["weakness", "NN"], ["caused", "VBN"], ["by", "IN"], ["illness", "NN"], ["or", "CC"], ["de-conditioning.", "NNP"], ["Focus", "NNP"], ["on", "IN"], ["overall", "JJ"], ["health", "NN"], ["Patients", "NNS"], ["may", "MD"], ["be", "VB"], ["cured", "VBN"], ["of", "IN"], ["cancer", "NN"], ["but", "CC"], ["still", "JJ"], ["face", "NN"], ["life-threatening", "JJ"], ["medical", "JJ"], ["problems", "NNS"], ["that", "WDT"], ["are", "VBP"], ["underemphasized", "JJ"], ["during", "IN"], ["cancer", "NN"], ["treatments", "NNS"], [",", ","], ["", ")"], ["such", "JJ"], ["as", "IN"], ["diabetes", "NN"], [",", ","], ["", ")"], ["high", "JJ"], ["blood", "NN"], ["pressure", "NN"], ["and", "CC"], ["heart", "NN"], ["disease.", "JJ"], ["Continue", "VB"], ["to", "TO"], ["monitor", "VB"], ["your", "PRP$"], ["overall", "JJ"], ["health.", "JJ"], ["Put", "NN"], ["the", "DT"], ["fire", "NN"], ["out", "IN"], ["for", "IN"], ["good", "JJ"], ["Smoking", "NNP"], ["impairs", "NNS"], ["healing", "NN"], ["after", "IN"], ["surgery", "NN"], ["and", "CC"], ["radiation", "NN"], ["and", "CC"], ["increases", "NNS"], ["your", "PRP$"], ["risk", "NN"], ["of", "IN"], ["cardiovascular", "JJ"], ["disease", "NN"], ["and", "CC"], ["many", "JJ"], ["types", "NNS"], ["of", "IN"], ["cancers.", "CD"], ["Ask", "VB"], ["your", "PRP$"], ["doctor", "NN"], ["for", "IN"], ["help", "NN"], ["identifying", "VBG"], ["and", "CC"], ["obtaining", "VBG"], ["the", "DT"], ["most", "RBS"], ["appropriate", "JJ"], ["cessation", "NN"], ["aids.", "NNP"], ["Map", "NNP"], ["a", "DT"], ["healthy", "JJ"], ["future", "NN"], ["Once", "RB"], ["youve", "VBP"], ["completed", "VBN"], ["treatment", "NN"], [",", ","], ["", ")"], ["discuss", "VB"], ["appropriate", "JJ"], ["follow-up", "NN"], ["plans", "NNS"], ["with", "IN"], ["your", "PRP$"], ["doctor", "NN"], ["and", "CC"], ["keep", "VB"], ["track", "NN"], ["of", "IN"], ["them", "PRP"], ["yourself.", "CD"], ["Intensified", "JJ"], ["screening", "NN"], ["over", "IN"], ["many", "JJ"], ["years", "NNS"], ["is", "VBZ"], ["frequently", "RB"], ["recommended", "VBN"], ["to", "TO"], ["identify", "VB"], ["and", "CC"], ["treat", "VB"], ["a", "DT"], ["recurrence", "NN"], ["early", "JJ"], ["on.", "CD"], ["Share", "VB"], ["your", "PRP$"], ["feelings", "NNS"], ["Allow", "VB"], ["yourself", "PRP"], ["time", "NN"], ["to", "TO"], ["discuss", "VB"], ["the", "DT"], ["emotional", "JJ"], ["consequences", "NNS"], ["of", "IN"], ["your", "PRP$"], ["illness", "NN"], ["and", "CC"], ["treatment", "NN"], ["with", "IN"], ["family", "NN"], [",", ","], ["", ")"], ["friends", "NNS"], [",", ","], ["", ")"], ["your", "PRP$"], ["doctor", "NN"], ["and", "CC"], [",", ","], ["", ")"], ["if", "IN"], ["necessary", "JJ"], [",", ","], ["", ")"], ["a", "DT"], ["professional", "JJ"], ["therapist.", "JJ"], ["Many", "JJ"], ["patients", "NNS"], ["also", "RB"], ["find", "VBP"], ["antidepressants", "NNS"], ["helpful", "JJ"], ["during", "IN"], ["treatment.", "JJ"], ["Stay", "VB"], ["connected", "VBN"], ["Although", "IN"], ["many", "JJ"], ["newly", "RB"], ["diagnosed", "VBN"], ["patients", "NNS"], ["fear", "VBP"], ["they", "PRP"], ["will", "MD"], ["not", "RB"], ["be", "VB"], ["able", "JJ"], ["to", "TO"], ["keep", "VB"], ["working", "VBG"], ["during", "IN"], ["treatment", "NN"], [",", ","], ["", ")"], ["this", "DT"], ["is", "VBZ"], ["usually", "RB"], ["not", "RB"], ["the", "DT"], ["case.", "CD"], ["Working", "NNP"], [",", ","], ["", ")"], ["even", "RB"], ["at", "IN"], ["a", "DT"], ["reduced", "VBN"], ["schedule", "NN"], [",", ","], ["", ")"], ["helps", "VBZ"], ["you", "PRP"], ["maintain", "VBP"], ["valuable", "JJ"], ["social", "JJ"], ["connections", "NNS"], ["and", "CC"], ["weekly", "JJ"], ["structure", "NN"], [".", "."]], pairs 
    #puts pairs.inspect
    # enable these lines for memory leak testing
    #$tagger = nil
    #ObjectSpace.garbage_collect
  end

  def test_multiple_docs
    timer = Time.now
    count = 0
    Dir["#{File.dirname(__FILE__)}/docs/doc*"].each do|doc|
      tagger.tag( File.read( doc ) )
      count += 1
    end
    duration = Time.now - timer
    puts "time: #{duration} sec #{count.to_f/duration} docs/sec"
  end

  def test_suggest
    results = tagger.suggest( SAMPLE_DOC )
    assert_equal [["doctor", "NN", 3], ["treatment", "NN", 5]], results
  end

private
  def tagger
    $rtagger
  end
end
