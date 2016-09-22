every 1.day, at: '9:00' do
  runner 'MailDigestJob.perform_later'
end
