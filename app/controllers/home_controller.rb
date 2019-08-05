class HomeController < ApplicationController
  def index
    @transactions = Transaction.all
  end
end
