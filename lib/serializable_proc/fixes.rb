# NOTE: This file contains hackeries to ensure compatibility with different rubies

unless 1.respond_to?(:pred)
  class Integer
    def pred
      self - 1
    end
  end
end
