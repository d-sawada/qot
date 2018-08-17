class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def nil.method_missing(*_);nil;end
end
