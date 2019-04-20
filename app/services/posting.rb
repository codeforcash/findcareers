#
# A job posting.
#
# +part_time?+ and +remote?+ default to +false+.
#
Posting = Struct.new(:title, :description, :url, :part_time, :remote) do
  def part_time?
    @part_time = false if @part_time.nil?
    @part_time
  end

  def remote?
    @remote = false if @remote.nil?
    @remote
  end
end
