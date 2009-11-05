require 'csv'

# Controller for showing global statistics
class StatisticsController < ApplicationController

  layout "admin"
  before_filter :authenticate

  # Shows available statistics grouped by term
  def index
    @terms = get_available_terms()
  end
  

  # Shows all events for a given term. It can also be used to download
  # or view visitors stats for a given event.
  def visitors
    
    @term = params[:id]
    @events = get_available_events(@term)
    

    # Only fetch statistics for a specific event or when downloading statistics as an .xls file.
    if !params[:event_id].nil? || params[:format] == "xls"
      
      if !params[:event_id].nil?
        @event = Event.find(params[:event_id])
	@visitor_stats = Event.get_visitor_stats_for_events( @term , [ @event ])
      else
        @visitor_stats = Event.get_visitor_stats_for_events( @term , @events)
      end

      # Output an xls file
      if params[:format] == "xls"
        xls_string =  get_visitor_stats_as_csv(@visitor_stats)
	my_iconv = Iconv.new("windows-1252" , "utf-8")
        xls_string.gsub!(/\n/,"\r\n")
	xls_string = my_iconv.iconv(xls_string);
        send_data xls_string, :filename => "visitors_stats_#{@term}.csv", :type => "text/csv; charset=windows-1252; header=present" , :disposition => 'inline'
      end
      
    end

  end

  def questionaires
    @term = params[:id]
    @events = get_available_events(@term)
    @events = @events.select { |e| ( ! e.questionaire.nil? ) && e.questionaire.answer_forms.count > 0 }
    if !params[:event_id].nil? || params[:format] == "xls" 
      @event = Event.find(params[:event_id])
      if ( ! @event.questionaire.nil? ) && @event.questionaire.answer_forms.count > 0 
        if params[:format] == "xls"
	  xls_string = get_questionaire_stats_as_csv(@event)
	  my_iconv = Iconv.new("windows-1252" , "utf-8")
	  xls_string = my_iconv.iconv(xls_string)
	  send_data xls_string , :filename => "questionaire_stats.csv",:type => "text/csv; charset=windows-1252; header=present" , :disposition => 'inline'
        end
      else
         @event = nil
      end      
    end
  end

  
  private

  def get_questionaire_stats_as_csv(event)
    res = ""
    CSV.generate_row(["Enkätsvar för #{event.name}"] ,1 , res , "\t")
    CSV.generate_row(["Antal besvarade enkäter" , "Antal obesvarade enkäter"],2,res, "\t")
    CSV.generate_row([event.questionaire.answer_forms.count(:all,:conditions => { :completed => true })] , 2 , res, "\t" )
    CSV.generate_row([event.questionaire.answer_forms.count(:all,:conditions => { :completed => false })] , 2 , res , "\t")
    CSV.generate_row([],0,res)
    CSV.generate_row([],0,res)
    CSV.generate_row([ "Fråga" , "Svar" ] ,2 , res, "\t")

    event.questionaire.questions.each do |q|
      row = []
      stat = q.statistic_for_event(event.id)
      case q.qtype
      when "QuestionMark"
        row = [ "#{q.question} (Genomsnittssvar)" ]
        row += [ stat[0] ]
        CSV.generate_row( row , row.length , res , "\t")
      when "QuestionText"
        row = [ "#{q.question} (Alla svar)" ]
        row += stat
        CSV.generate_row( row , row.length , res , "\t") 
      when "QuestionBool"
        row = [ "#{q.question} (Procent ja-svar , Procent nej-svar)" ]
        row += stat
        CSV.generate_row( row , row.length , res , "\t")
      when "QuestionMchoice"
        row = [ "#{q.question} (Antal för varje ord)" ]
        row += q.choice_csv.split(",")
        CSV.generate_row( row , row.length , res , "\t") 
        row = [""]
        row += stat
        CSV.generate_row( row , row.length , res , "\t") 
      end
    end
    return res
  end

  # Returns all avaiable terms in an array
  # The format of a term is "ht|vtYYYY", e.g. ht2007 (autumn term 2007)
  # vt = vårtermin. ht = hösttermin
  def get_available_terms

    # Begins at fall 2001
    available_terms = []
    2009.upto(Time.now.year.to_i) do |year|

      num_vt = Occasion.count :all, :conditions => "date between '#{year}-01-01' and '#{year}-06-30'"
      num_ht = Occasion.count :all, :conditions => "date between '#{year}-07-01' and '#{year}-12-31'"

      available_terms << "vt#{year}" if num_vt > 0
      available_terms << "ht#{year}" if num_ht > 0

    end

    return available_terms
  end

  # Returns all available events for a given term
  # The format of a term is "ht|vtYYYY", e.g. ht2007 (autumn term 2007)
  def get_available_events(term)
    term, year = term.scan(/^(vt|ht)(20[01][0-9])$/).first

    if term == 'vt'
      from = "#{year}-01-01"
      to = "#{year}-06-30"
    else
      from = "#{year}-07-01"
      to = "#{year}-12-31"
    end

    Event.find :all, :include => :culture_provider,
      :conditions => [ "events.id in (select event_id from occasions where occasions.date between ? and ?)", from, to ]
  end

  # Returns a comma-seperated values (CSV) string
  def get_visitor_stats_as_csv(visitor_stats)
    output_buffer = ""
    row = ["Stadsdel" , "Skola" , "Grupp" , "Föreställning" , "Antal bokade" , "Antal barn" , "Antal vuxna" ]

    CSV.generate_row(row, row.length, output_buffer, "\t")

    visitor_stats.each do |v|
      row = [ v["district_name"] , v["school_name"] ,v["group_name"] ,v["event_name"] ,v["num_booked"] ,v["num_children"] ,v["num_adult"] ]
      CSV.generate_row(row, row.length, output_buffer, "\t")
    end

    return output_buffer
  end

end