require 'test/unit'
$:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")
$:.unshift File.join(File.dirname(__FILE__), "..", "..", "ext")

require 'brill/tagger'
puts "loading tagger..."
$tagger = Brill::Tagger.new( File.join(File.dirname(__FILE__),"LEXICON"),
                             File.join(File.dirname(__FILE__),"LEXICALRULEFILE"),
                             File.join(File.dirname(__FILE__),"CONTEXTUALRULEFILE") )
puts "tagger loaded!"

class TaggerTest < Test::Unit::TestCase
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
  def test_simple_tagger
    pairs = tagger.tag( SAMPLE_DOC )
    puts pairs.inspect
  end

  def test_multiple_docs
    timer = Time.now
    count = 0
    Dir["#{File.dirname(__FILE__)}/docs/doc*"].each do|doc|
      tagger.tag( File.read( doc ) )
      count += 1
    end
    duration = Time.now - timer
    puts "time: #{duration} sec #{duration/count.to_f} docs/sec"
  end

private
  def tagger
    $tagger
  end
end
