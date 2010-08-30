class BasicOperationWorker < Workling::Base

  def do_work(input)
    File.open(output_file_name, "w") do |f|
      f.write(input[:token])
    end
  end

  private
    def output_file_name
      File.join(File.dirname(__FILE__), "../tmp/basic_operation.output")
    end

end