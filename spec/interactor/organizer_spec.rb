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
  end
end
