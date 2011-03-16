Factory.define :report do |f|
  f.name    "simple"
  f.title   "Simple Report"
  f.columns [:signature, :title, :document_count]
end
