module Interactor
  describe Organizer do
    include_examples :lint

    let(:organizer) { Class.new.send(:include, Organizer) }

    describe ".organize" do
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }
      let(:interactor4) { double(:interactor4) }

      it "sets interactors given class arguments" do
        expect {
          organizer.organize(interactor2, interactor3)
        }.to change {
          organizer.organized
        }.from([]).to([{ interactor: interactor2, condition: true }, { interactor: interactor3, condition: true }])
      end

      it "sets interactors given an array of classes" do
        expect {
          organizer.organize([interactor2, interactor3])
        }.to change {
          organizer.organized
        }.from([]).to([{ interactor: interactor2, condition: true }, { interactor: interactor3, condition: true }])
      end

      it "sets interactors given class arguments mixed with hash argument" do
        expect {
          organizer.organize(interactor2, { interactor: interactor3, condition: false }, interactor4)
        }.to change {
          organizer.organized
        }.from([]).to([{ interactor: interactor2, condition: true }, { interactor: interactor3, condition: false }, { interactor: interactor4, condition: true }])
      end
    end

    describe ".organized" do
      it "is empty by default" do
        expect(organizer.organized).to eq([])
      end
    end

    describe "#call" do
      let(:instance) { organizer.new }
      let(:context) { double(:context) }
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }
      let(:interactor4) { double(:interactor4) }
      let(:interactor5) { double(:interactor5) }

      before do
        allow(instance).to receive(:context) { context }
        allow(organizer).to receive(:organized) {
          [
            { interactor: interactor2, condition: true }, 
            { interactor: interactor3, condition: true }, 
            { interactor: interactor4, condition: true }, 
            { interactor: interactor5, condition: false }
          ]
        }
      end

      it "calls each interactor in order with the context" do
        expect(interactor2).to receive(:call!).once.with(context).ordered
        expect(interactor3).to receive(:call!).once.with(context).ordered
        expect(interactor4).to receive(:call!).once.with(context).ordered
        expect(interactor4).not_to receive(:call!)

        instance.call
      end
    end

    describe "#call" do
      def build_organizer(options = {}, &block)
        organizer = Class.new.send(:include, Interactor::Organizer).send(:requires, :something_awesome)
        organizer.organize(options[:organize]) if options[:organize]
        organizer.class_eval(&block) if block
        organizer
      end


      let!(:a_rainbow) { double(:awesome_thing, rainbow?: true, unicorn?: false) }
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }
      let(:context) { double(:context) }
      # let(:organizer) do
      #   Class.new do
          
      #     include Interactor::Organizer

      #     requires :something_awesome

      #     organize(
      #       { interactor: 'bla', condition: something_awesome }, 
      #       { interactor: 'tuk', condition: something_awesome })

      #     def self.something_awesome
      #       true
      #     end

      #     def something_awesome
      #       true
      #     end
      #   end
      # end
      let(:organizer) { build_organizer(organize: [
        { interactor: interactor2, condition: something_awesome.rainbow? }, 
        { interactor: interactor3, condition: something_awesome.unicorn? }]) }

      subject { organizer.call(something_awesome: a_rainbow) }

      before do
        allow(subject).to receive(:context) { context }
      end

      it 'calls only interactor2 and without errors' do
        # expect(interactor2).to receive(:call!)
        # expect(interactor3).not_to receive(:call!)
        expect { subject }.to_not raise_error

        subject
      end
    end
  end
end
