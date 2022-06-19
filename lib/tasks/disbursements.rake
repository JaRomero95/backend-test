namespace :disbursements do
  desc 'Allows to run DisbursementsGenerator from CLI'

  task :generator, [:date] => [:environment] do |_task, args|
    date = args.fetch :date, 1.week.ago.strftime('%d/%m/%Y')

    DisbursementsGeneratorJob.perform_now(date)
  end
end
