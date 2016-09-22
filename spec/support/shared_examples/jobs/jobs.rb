shared_examples_for :delayed_job do
  it 'should put new job in a queue' do
    expect { described_class.perform_later(args) }.to have_enqueued_job.with(args)
  end
end
