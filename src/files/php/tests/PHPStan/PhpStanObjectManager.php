<?php

/**
 * @copyright 2025 Biapy
 * @license MIT
 */

declare(strict_types=1);

namespace App\Tests\PhpStan;

use Doctrine\Persistence\ManagerRegistry;
use Doctrine\Persistence\Mapping\ClassMetadata;
use Doctrine\Persistence\Mapping\ClassMetadataFactory;
use Doctrine\Persistence\ObjectManager;
use Doctrine\Persistence\ObjectRepository;

/**
 * Proxy class to detect the correct object manager.
 *
 * @SuppressWarnings("PHPMD.TooManyPublicMethods")
 */
final class PhpStanObjectManager implements ObjectManager
{
    private ?ObjectManager $manager = null;

    /**
     * @var PhpStanMetadataFactory<ClassMetadata<object>>
     */
    private readonly ClassMetadataFactory $metadataFactory;

    /**
     * @param non-empty-list<ManagerRegistry> $doctrineRegistries
     */
    public function __construct(
        private array $doctrineRegistries,
    ) {
        $this->metadataFactory = new PhpStanMetadataFactory($doctrineRegistries);
    }

    /**
     * @param class-string<T> $className
     *
     * @return ObjectRepository<T>
     *
     * @template T of object
     */
    #[\Override]
    public function getRepository(string $className): ObjectRepository
    {
        return $this->getManagerForClass($className)->getRepository($className);
    }

    /**
     * @param class-string $className
     * @psalm-param class-string<T> $className
     *
     * @return ClassMetadata<object>
     * @psalm-return ClassMetadata<T>
     *
     * @template T of object
     */
    #[\Override]
    public function getClassMetadata(string $className): ClassMetadata
    {
        /** @psalm-var ClassMetadata<T> $result */
        $result = $this->metadataFactory->getMetadataFor($className);

        return $result;
    }

    /**
     * @return ClassMetadataFactory<ClassMetadata<object>> $metadataFactory
     */
    #[\Override]
    public function getMetadataFactory(): ClassMetadataFactory
    {
        return $this->metadataFactory;
    }

    /**
     * @param class-string<O> $className
     *
     * @return O|null
     *
     * @template O of object
     */
    #[\Override]
    public function find(string $className, mixed $id): ?object
    {
        return $this->getManagerForClass($className)->find($className, $id);
    }

    #[\Override]
    public function persist(object $object): void
    {
        $this->getManagerForClass($object::class)->persist($object);
    }

    #[\Override]
    public function remove(object $object): void
    {
        $this->getManagerForClass($object::class)->remove($object);
    }

    public function merge(object $object): void
    {
        $manager = $this->getManagerForClass($object::class);
        if (method_exists($manager, 'merge')) {
            $manager->merge($object);
        }
    }

    /**
     * @SuppressWarnings("PHPMD.UnusedFormalParameter")
     */
    #[\Override]
    public function clear(?string $objectName = null): void
    {
        $args = func_get_args();

        $this->getManager()->clear(...$args);
    }

    #[\Override]
    public function detach(object $object): void
    {
        $this->getManagerForClass($object::class)->detach($object);
    }

    #[\Override]
    public function refresh(object $object): void
    {
        $this->getManagerForClass($object::class)->refresh($object);
    }

    /**
     * @param mixed[] ...$args
     */
    #[\Override]
    public function flush(...$args): void
    {
        $this->getManager()->flush(...$args);
    }

    #[\Override]
    public function initializeObject(object $obj): void
    {
        $this->getManagerForClass($obj::class)->initializeObject($obj);
    }

    public function isUninitializedObject(mixed $value): bool
    {
        if (!is_object($value)) {
            return false;
        }

        return $this->getManagerForClass($value::class)->isUninitializedObject($value);
    }

    #[\Override]
    public function contains(object $object): bool
    {
        try {
            return $this->getManagerForClass($object::class)->contains($object);
        } catch (\Exception) {
            return false;
        }
    }

    /**
     * Get the object manager for the given class.
     *
     * @param class-string $className Class name which manager is needed
     */
    private function getManagerForClass(string $className): ObjectManager
    {
        // Try to find manager by name in all registries.
        foreach ($this->doctrineRegistries as $doctrineRegistry) {
            $manager = $doctrineRegistry->getManagerForClass($className);

            if ($manager instanceof ObjectManager) {
                $this->manager = $manager;

                return $this->manager;
            }
        }

        return $this->getManager();
    }

    /**
     * Get the default object manager, or the manager for the given name.
     *
     * @throws \InvalidArgumentException If no manager is found for given name
     */
    private function getManager(?string $name = null): ObjectManager
    {
        if (null === $name) {
            // Fall back to first registry default manager.
            reset($this->doctrineRegistries);

            return current($this->doctrineRegistries)->getManager();
        }

        // Try to find manager by name in all registries.
        foreach ($this->doctrineRegistries as $doctrineRegistry) {
            try {
                $manager = $doctrineRegistry->getManager($name);

                $this->manager = $manager;

                return $this->manager;
            } catch (\Exception) {
                // Named manager not found in current registry. Try next one.
                continue;
            }
        }

        throw new \InvalidArgumentException(sprintf('Doctrine Manager named "%s" does not exist.', $name));
    }
}
