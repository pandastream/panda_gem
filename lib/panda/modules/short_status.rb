module ShortStatus
  def success?
    @attributes['status'] == 'success'
  end

  def processing?
    @attributes['status'] == 'processing'
  end

  def fail?
    @attributes['status'] == 'fail'
  end
end