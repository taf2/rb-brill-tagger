# encoding: utf-8
$:.unshift File.expand_path(File.dirname(__FILE__))
require 'test_helper'


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

SAMPLE_DOC2=%q(
Britney Spears was granted a change in her visitation schedule with her sons Sean Preston and Jayden James at a hearing Tuesday.
"There was a change in visitation status that was ordered by Commissioner Gordon this morning," Los Angeles Superior Court spokesperson Alan Parachini confirmed after the hearing, which both Kevin Federline and her father (and co-conservator) Jamie Spears attended. (Britney and Kevin did not address each other during the hearing.)
The details of her visitation, however, are unclear.
"I'm not at liberty to answer any questions about the nature of that change," Parachini said. (TMZ.com had reported that Spears wanted overnight visits.)
Asked by Us if she were happy with the court outcome, Spears (clutching an Ed Hardy purse) smiled and told Us, "Yes."
Next up: A status hearing set for July 15.
The couple last appeared in court May 6. Spears was granted extended visitation — three days a week from 9 a.m. to 5 p.m. — of Sean Preston, 2, and Jayden James, 20 months. 
)
SAMPLE_DOC3=%q(
TMZ.com: Britney celebrated getting overnights with her kids by going on a wild shopping trip for herself.With L.A.'s finest at her service, it was a total clusterf**k outside of Fred Segal as Brit Brit made her way out. The scene was crazy -- and it was all... Read more
)
  def setup
    if !defined?($tagger)
      $rtagger = Brill::Tagger.new
    end
  end

  def test_simple_tagger
    pairs = tagger.tag( SAMPLE_DOC )
    tags = [["", ")"], ["", ")"], ["Take", "VB"], ["an", "DT"], ["active", "JJ"], ["role", "NN"], ["in", "IN"],
            ["your", "PRP$"], ["care", "NN"], ["When", "WRB"], ["it", "PRP"], ["comes", "VBZ"], ["to", "TO"],
            ["making", "VBG"], ["decisions", "NNS"], ["about", "IN"], ["the", "DT"], ["goals", "NNS"], ["and", "CC"],
            ["direction", "NN"], ["of", "IN"], ["treatment", "NN"], [",", ","], ["", ")"], ["do", "VBP"], ["", ")"],
            ["n't", "RB"], ["sit", "VB"], ["back.", "CD"], ["Work", "NN"], ["closely", "RB"], ["and", "CC"],
            ["actively", "RB"], ["with", "IN"], ["your", "PRP$"], ["oncologist", "NN"], ["and", "CC"], ["the", "DT"],
            ["rest", "NN"], ["of", "IN"], ["your", "PRP$"], ["medical", "JJ"], ["team.", "JJ"], ["Do", "VBP"],
            ["", ")"], ["n't", "RB"], ["overlook", "VB"], ["clinical", "JJ"], ["trials", "NNS"], ["If", "IN"],
            ["you", "PRP"], ["'re", "VBP"], ["eligible", "JJ"], ["to", "TO"], ["enroll", "VB"], ["in", "IN"],
            ["clinical", "JJ"], ["trials", "NNS"], [",", ","], ["", ")"], ["select", "VB"], ["an", "DT"],
            ["oncologist", "NN"], ["who", "WP"], ["participates", "VBZ"], ["in", "IN"], ["them.", "JJ"],
            ["Patients", "NNS"], ["who", "WP"], ["enroll", "VBP"], ["in", "IN"], ["clinical", "JJ"],
            ["studies", "NNS"], ["receive", "VBP"], ["closer", "JJR"], ["follow-up", "NN"], [",", ","], ["", ")"],
            ["the", "DT"], ["highest", "JJS"], ["standard-of-care", "JJ"], ["treatment", "NN"], ["and", "CC"],
            ["access", "NN"], ["to", "TO"], ["experimental", "JJ"], ["therapies", "NNS"], ["at", "IN"], ["no", "DT"],
            ["extra", "JJ"], ["cost.", "NNP"], ["Maximize", "NNP"], ["your", "PRP$"], ["nutrition", "NN"],
            ["strategy", "NN"], ["Doing", "NNP"], ["your", "PRP$"], ["best", "JJS"], ["to", "TO"], ["eat", "VB"],
            ["a", "DT"], ["healthy", "JJ"], [",", ","], ["", ")"], ["well-balanced", "JJ"], ["diet", "NN"],
            ["is", "VBZ"], ["vital", "JJ"], ["to", "TO"], ["prompt", "VB"], ["healing", "NN"], ["after", "IN"],
            ["surgery", "NN"], ["and", "CC"], ["for", "IN"], ["recovery", "NN"], ["from", "IN"], ["radiation", "NN"],
            ["or", "CC"], ["chemotherapy.", "JJ"], ["Many", "JJ"], ["oncology", "NN"], ["practices", "NNS"],
            ["employ", "VBP"], ["registered", "VBN"], ["dieticians", "NNS"], ["who", "WP"], ["can", "MD"],
            ["help", "VB"], ["you", "PRP"], ["optimize", "VB"], ["your", "PRP$"], ["nutrition.", "JJ"],
            ["Steer", "VB"], ["clear", "JJ"], ["of", "IN"], ["", ")"], ["``", "``"], ["natural", "JJ"],
            ["cures", "NNS"], ["''", "''"], ["", ")"], ["Before", "IN"], ["trying", "VBG"], ["nutritional", "JJ"],
            ["supplements", "NNS"], ["or", "CC"], ["herbal", "JJ"], ["remedies", "NNS"], [",", ","], ["", ")"],
            ["be", "VB"], ["sure", "JJ"], ["to", "TO"], ["discuss", "VB"], ["your", "PRP$"], ["plans", "NNS"],
            ["with", "IN"], ["a", "DT"], ["doctor.", "JJ"], ["Most", "JJS"], ["have", "VBP"], ["not", "RB"],
            ["been", "VBN"], ["tested", "VBN"], ["in", "IN"], ["clinical", "JJ"], ["studies", "NNS"], [",", ","],
            ["", ")"], ["and", "CC"], ["some", "DT"], ["may", "MD"], ["actually", "RB"], ["interfere", "VB"],
            ["with", "IN"], ["your", "PRP$"], ["treatment.", "JJ"], ["Build", "VB"], ["a", "DT"], ["stronger", "JJR"],
            ["body", "NN"], ["Even", "RB"], ["walking", "VBG"], ["regularly", "RB"], ["is", "VBZ"], ["can", "MD"],
            ["help", "VB"], ["you", "PRP"], ["minimize", "VB"], ["long-term", "JJ"], ["muscle", "NN"],
            ["weakness", "NN"], ["caused", "VBN"], ["by", "IN"], ["illness", "NN"], ["or", "CC"],
            ["de-conditioning.", "NNP"], ["Focus", "NNP"], ["on", "IN"], ["overall", "JJ"], ["health", "NN"],
            ["Patients", "NNS"], ["may", "MD"], ["be", "VB"], ["cured", "VBN"], ["of", "IN"], ["cancer", "NN"],
            ["but", "CC"], ["still", "JJ"], ["face", "NN"], ["life-threatening", "JJ"], ["medical", "JJ"],
            ["problems", "NNS"], ["that", "WDT"], ["are", "VBP"], ["underemphasized", "JJ"], ["during", "IN"],
            ["cancer", "NN"], ["treatments", "NNS"], [",", ","], ["", ")"], ["such", "JJ"], ["as", "IN"],
            ["diabetes", "NN"], [",", ","], ["", ")"], ["high", "JJ"], ["blood", "NN"], ["pressure", "NN"],
            ["and", "CC"], ["heart", "NN"], ["disease.", "JJ"], ["Continue", "VB"], ["to", "TO"], ["monitor", "VB"],
            ["your", "PRP$"], ["overall", "JJ"], ["health.", "JJ"], ["Put", "NN"], ["the", "DT"], ["fire", "NN"],
            ["out", "IN"], ["for", "IN"], ["good", "JJ"], ["Smoking", "NNP"], ["impairs", "NNS"], ["healing", "NN"],
            ["after", "IN"], ["surgery", "NN"], ["and", "CC"], ["radiation", "NN"], ["and", "CC"], ["increases", "NNS"],
            ["your", "PRP$"], ["risk", "NN"], ["of", "IN"], ["cardiovascular", "JJ"], ["disease", "NN"], ["and", "CC"],
            ["many", "JJ"], ["types", "NNS"], ["of", "IN"], ["cancers.", "CD"], ["Ask", "VB"], ["your", "PRP$"],
            ["doctor", "NN"], ["for", "IN"], ["help", "NN"], ["identifying", "VBG"], ["and", "CC"], ["obtaining", "VBG"],
            ["the", "DT"], ["most", "RBS"], ["appropriate", "JJ"], ["cessation", "NN"], ["aids.", "NNP"], ["Map", "NNP"],
            ["a", "DT"], ["healthy", "JJ"], ["future", "NN"], ["Once", "RB"], ["youve", "VBP"], ["completed", "VBN"],
            ["treatment", "NN"], [",", ","], ["", ")"], ["discuss", "VB"], ["appropriate", "JJ"], ["follow-up", "NN"],
            ["plans", "NNS"], ["with", "IN"], ["your", "PRP$"], ["doctor", "NN"], ["and", "CC"], ["keep", "VB"],
            ["track", "NN"], ["of", "IN"], ["them", "PRP"], ["yourself.", "CD"], ["Intensified", "JJ"], ["screening", "NN"],
            ["over", "IN"], ["many", "JJ"], ["years", "NNS"], ["is", "VBZ"], ["frequently", "RB"], ["recommended", "VBN"],
            ["to", "TO"], ["identify", "VB"], ["and", "CC"], ["treat", "VB"], ["a", "DT"], ["recurrence", "NN"], ["early", "JJ"],
            ["on.", "CD"], ["Share", "VB"], ["your", "PRP$"], ["feelings", "NNS"], ["Allow", "VB"], ["yourself", "PRP"],
            ["time", "NN"], ["to", "TO"], ["discuss", "VB"], ["the", "DT"], ["emotional", "JJ"], ["consequences", "NNS"],
            ["of", "IN"], ["your", "PRP$"], ["illness", "NN"], ["and", "CC"], ["treatment", "NN"], ["with", "IN"],
            ["family", "NN"], [",", ","], ["", ")"], ["friends", "NNS"], [",", ","], ["", ")"], ["your", "PRP$"],
            ["doctor", "NN"], ["and", "CC"], [",", ","], ["", ")"], ["if", "IN"], ["necessary", "JJ"], [",", ","],
            ["", ")"], ["a", "DT"], ["professional", "JJ"], ["therapist.", "JJ"], ["Many", "JJ"], ["patients", "NNS"],
            ["also", "RB"], ["find", "VBP"], ["antidepressants", "NNS"], ["helpful", "JJ"], ["during", "IN"],
            ["treatment.", "JJ"], ["Stay", "VB"], ["connected", "VBN"], ["Although", "IN"], ["many", "JJ"],
            ["newly", "RB"], ["diagnosed", "VBN"], ["patients", "NNS"], ["fear", "VBP"], ["they", "PRP"], ["will", "MD"],
            ["not", "RB"], ["be", "VB"], ["able", "JJ"], ["to", "TO"], ["keep", "VB"], ["working", "VBG"], ["during", "IN"],
            ["treatment", "NN"], [",", ","], ["", ")"], ["this", "DT"], ["is", "VBZ"], ["usually", "RB"], ["not", "RB"],
            ["the", "DT"], ["case.", "CD"], ["Working", "NNP"], [",", ","], ["", ")"], ["even", "RB"], ["at", "IN"],
            ["a", "DT"], ["reduced", "VBN"], ["schedule", "NN"], [",", ","], ["", ")"], ["helps", "VBZ"], ["you", "PRP"],
            ["maintain", "VBP"], ["valuable", "JJ"], ["social", "JJ"], ["connections", "NNS"], ["and", "CC"],
            ["weekly", "JJ"], ["structure", "NN"], [".", "."]]
    assert_equal tags, pairs 
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
#    puts results.inspect
    assert results.include?(["treatment", "NN", 5])
    results = tagger.suggest( SAMPLE_DOC2 )
    assert results.include?(["Britney Spears", "NNP", 6])
    assert results.include?(["Jamie Spears", "NNP", 12])
#    puts results.inspect
    results = tagger.suggest( SAMPLE_DOC3, 5 )
    puts results.inspect
  end

  def test_noun_phrases
    results = tagger.noun_phrases( SAMPLE_DOC )
    puts results.inspect
    results.map{|phrase| puts phrase.inspect }
    puts 
    results = tagger.noun_phrases( SAMPLE_DOC2 )
    puts results.inspect
    puts 
    results = tagger.noun_phrases( SAMPLE_DOC3 )
    puts results.inspect
  end

  def test_adjectives
    results = tagger.adjectives("So happy i get to bring my baby boy home tomorrow. Hospital tv is horrible, ten channels no one watches")
    assert_equal [["happy", "JJ"], ["horrible", "JJ"]], results
  end

private
  def tagger
    $rtagger
  end
end
