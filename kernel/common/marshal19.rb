# -*- encoding: us-ascii -*-

class Class
  def __marshal__(ms)
    if Rubinius::Type.singleton_class_object(self)
      raise TypeError, "singleton class can't be dumped"
    elsif name.nil? || name.empty?
      raise TypeError, "can't dump anonymous module #{self}"
    end

    "c#{ms.serialize_integer(name.length)}#{name}"
  end
end

class Module
  def __marshal__(ms)
    raise TypeError, "can't dump anonymous module #{self}" if name.nil? || name.empty?
    "m#{ms.serialize_integer(name.length)}#{name}"
  end
end

module Marshal
  class State
    def serialize_encoding?(obj)
      enc = Rubinius::Type.object_encoding(obj)
      enc && enc != Encoding::BINARY
    end

    def serialize_encoding(obj)
      case enc = Rubinius::Type.object_encoding(obj)
        when Encoding::US_ASCII
          serialize_symbol(:E) + false.__marshal__(self)
        when Encoding::UTF_8
          serialize_symbol(:E) + true.__marshal__(self)
        else
          serialize_symbol(:encoding) + serialize_string(enc.name)
      end
    end
  end
end
