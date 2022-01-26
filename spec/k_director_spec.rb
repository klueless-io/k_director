# frozen_string_literal: true

RSpec.describe KDirector do
  it 'has a version number' do
    expect(KDirector::VERSION).not_to be nil
  end

  it 'has a standard error' do
    expect { raise KDirector::Error, 'some message' }
      .to raise_error('some message')
  end
end
