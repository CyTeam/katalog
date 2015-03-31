require 'spec_helper'

describe Reservation do
  subject do
    Reservation.new(
      email: 'user@example.com',
      first_name: 'John',
      last_name: 'Doe',
      dossier_years: '2015',
      pickup: Date.today,
    )
  end

  context 'validations' do
    describe 'pickup' do
      it 'accepts a week day that is not a holiday' do
        [ '2015-01-05', '2015-02-20', '2015-03-31' ].each do |date|
          subject.pickup = date
          subject.valid?
          expect(subject).to be_valid
        end
      end

      it 'rejects weekend days' do
        [ '2015-01-03', '2015-02-22', '2015-03-01' ].each do |date|
          subject.pickup = date
          expect(subject).to_not be_valid
          expect(subject.errors[:pickup].first).to match(/^Datum ist an einem Wochenende \((Samstag|Sonntag)\)$/)
        end
      end

      it 'rejects holidays' do
        [ '2015-01-01', '2015-04-03', '2015-04-06', '2015-05-25' ].each do |date|
          subject.pickup = date
          expect(subject).to_not be_valid
          expect(subject.errors[:pickup].first).to match(/^Datum ist an einem Feiertag \((Neujahrstag|Karfreitag|Ostermontag|Pfingstmontag)\)$/)
        end
      end
    end
  end
end
